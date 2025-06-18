from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import mysql.connector
import json
from datetime import datetime
# MySQL 설정
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "kboPj"
}

team_name_map = {
    '두산': 'doosan',
    'LG': 'lg',
    '삼성': 'samsung',
    '한화': 'hanwha',
    'SSG': 'ssg',
    'NC': 'nc',
    '롯데': 'lotte',
    '키움': 'kiwoom',
    'KT': 'kt',
    'KIA': 'kia',
}
# Selenium 초기화
def init_driver():
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_experimental_option('excludeSwitches', ['enable-logging'])  # 불필요한 로그 억제
    service = Service(ChromeDriverManager().install())
    return webdriver.Chrome(service=service, options=options)

def safe_int(s, default=0):
    try:
        return int(s)
    except (ValueError, TypeError):
        return default
def structure_innings(raw_data, home_team_name, away_team_name):
    return {
        "home_team": {
            "name": home_team_name,
            "innings": raw_data.get(home_team_name, {}),
            "total": {
                'R': raw_data[home_team_name]['R'],
                'H': raw_data[home_team_name]['H'],
                'E': raw_data[home_team_name]['E'],
                'B': raw_data[home_team_name]['B']
            }
        },
        "away_team": {
            "name": away_team_name,
            "innings": raw_data.get(away_team_name, {}),
            "total": {
                'R': raw_data[away_team_name]['R'],
                'H': raw_data[away_team_name]['H'],
                'E': raw_data[away_team_name]['E'],
                'B': raw_data[away_team_name]['B']
            }
        }
    }
# 이닝 데이터를 MySQL JSON 타입에 맞게 변환
def convert_for_mysql(structured_data):
    return {
        "home_innings": json.dumps(structured_data["home_team"]["innings"]),
        "away_innings": json.dumps(structured_data["away_team"]["innings"]),
        "home_total": json.dumps(structured_data["home_team"]["total"]),
        "away_total": json.dumps(structured_data["away_team"]["total"])
    }


def parse_games(html):
    soup = BeautifulSoup(html, 'html.parser')
    games = []
    
    date_str = soup.find('span', {'id': 'cphContents_cphContents_cphContents_lblGameDate'}).text
    clean_date = date_str[:10] 
    game_date = datetime.strptime(clean_date, "%Y.%m.%d").date()


    for game in soup.find_all('div', class_='smsScore'):
        # 홈팀/원정팀 정보 추출 (생략)
        home_team = game.find('p', class_='rightTeam').strong.text.strip()
        away_team = game.find('p', class_='leftTeam').strong.text.strip()
        # 이닝별 점수 추출 로직 변경
        innings_data = {
            "home_innings": {},
            "away_innings": {},
            "home_total": {},
            "away_total": {}
        }
        
        rows = game.select('table.tScore tbody tr')
        for i, row in enumerate(rows):
            cells = row.find_all(['th', 'td'])
            team_type = 'home' if i == 1 else 'away'  # 0:원정팀, 1:홈팀
            
            innings = {str(inning+1): safe_int(cells[inning+1].text) 
                for inning in range(12)}
            
            # 총점 (R, H, E, B)
            totals = {
                'R': safe_int(cells[13].text),
                'H': safe_int(cells[14].text),
                'E': safe_int(cells[15].text),
                'B': safe_int(cells[16].text)
            }
            
            if team_type == 'home':
                innings_data['home_innings'] = innings
                innings_data['home_total'] = totals
            else:
                innings_data['away_innings'] = innings
                innings_data['away_total'] = totals
        game_data = {
            'date': game_date,
            'home_team': home_team,
            'away_team': away_team,
            'home_emblem': game.find('p', class_='rightTeam').img['src'],
            'away_emblem': game.find('p', class_='leftTeam').img['src'],
            'venue': game.find('p', class_='place').text.split()[0],
            'home_score': safe_int(game.find('span', id=lambda x: x and 'lblHomeTeamScore' in x).text),
            'away_score': safe_int(game.find('span', id=lambda x: x and 'lblAwayTeamScore' in x).text),
            'innings': innings_data 
        }
        games.append(game_data)
    
    return games

def save_to_db(games):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        # 팀 정보 저장
        for game in games:
            home_team_value = team_name_map[game['home_team']]
            away_team_value = team_name_map[game['away_team']]
            cursor.execute("""
                INSERT INTO scoreboard (
                    game_date, home_team_id, away_team_id, 
                    venue, home_score, away_score, 
                    home_innings, away_innings,
                    home_total, away_total
                ) VALUES (
                    %s, 
                    (SELECT teamID FROM kboteam WHERE teamValue = %s),
                    (SELECT teamID FROM kboteam WHERE teamValue = %s),
                    %s, %s, %s, 
                    %s, %s,
                    %s, %s
                )
                    ON DUPLICATE KEY UPDATE
                    home_score = VALUES(home_score),
                    away_score = VALUES(away_score),
                    home_innings = VALUES(home_innings),
                    away_innings = VALUES(away_innings),
                    home_total = VALUES(home_total),
                    away_total = VALUES(away_total)
            """, (
                game['date'],
                home_team_value,  
                away_team_value,  
                game['venue'],
                game['home_score'],
                game['away_score'],
                json.dumps(game['innings']['home_innings']),
                json.dumps(game['innings']['away_innings']),
                json.dumps(game['innings']['home_total']),
                json.dumps(game['innings']['away_total'])
            ))
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        cursor.close()
        conn.close()

# 메인 실행
def main():
    try:
        driver = init_driver()
        wait = WebDriverWait(driver, 15)        

        def navigate_and_scrape(btn_id):
            try:
                btn = wait.until(EC.element_to_be_clickable((By.ID, btn_id)))
                btn.click()
                wait.until(EC.staleness_of(btn))
                wait.until(EC.presence_of_element_located((By.CLASS_NAME, "smsScore")))
                games = parse_games(driver.page_source)
                save_to_db(games)
                print(f"{len(games)}개의 경기 데이터 저장 완료")
            except Exception as e:
                print(f"이동 실패: {str(e)}")

        driver.get("https://www.koreabaseball.com/Schedule/ScoreBoard.aspx")

        # 2. 전날 데이터 수집
        navigate_and_scrape("cphContents_cphContents_cphContents_btnPreDate")

        # 3. 다음날 데이터 수집 (원래 날짜로 복귀 후 이동)
        navigate_and_scrape("cphContents_cphContents_cphContents_btnNextDate")  # 원래 날짜 복귀
        navigate_and_scrape("cphContents_cphContents_cphContents_btnNextDate")  # 실제 다음날 이동        
    except Exception as e:
        print(f"에러 발생: {str(e)}")
    finally:
        driver.quit()

if __name__ == "__main__":
    main()

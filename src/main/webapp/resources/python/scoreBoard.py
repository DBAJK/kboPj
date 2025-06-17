from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import mysql.connector
import time
import os
import json
from datetime import datetime

class KboScoreCrawler:
    def __init__(self):
        # WebDriver 초기화
        self.service = Service(ChromeDriverManager().install())
        self.options = webdriver.ChromeOptions()
        self.options.add_argument("--headless")
        self.driver = webdriver.Chrome(service=self.service, options=self.options)

        # DB 연결
        self.db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="1234",
            database="cproject"
        )
        self.cursor = self.db.cursor()

    def get_scoreboard(self):
        self.driver.get("https://www.koreabaseball.com/Schedule/ScoreBoard.aspx")
        WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, "smsScore"))
        )
        return self._parse_scoreboard()

    def _parse_scoreboard(self):
        games = []
        for game in self.driver.find_elements(By.CLASS_NAME, "smsScore"):
            game_data = {
                "teams": self._get_teams(game),
                "innings": self._get_innings(game),
                "current_status": self._get_current_status(game),
                "game_info": self._get_game_info(game)
            }
            games.append(game_data)
        return games

    def _get_teams(self, game_element):
        return {
            "away": {
                "name": game_element.find_element(By.CLASS_NAME, "leftTeam").find_element(By.CLASS_NAME, "teamT").text,
                "score": game_element.find_element(By.CLASS_NAME, "leftTeam").find_element(By.CLASS_NAME, "score").text
            },
            "home": {
                "name": game_element.find_element(By.CLASS_NAME, "rightTeam").find_element(By.CLASS_NAME, "teamT").text,
                "score": game_element.find_element(By.CLASS_NAME, "rightTeam").find_element(By.CLASS_NAME, "score").text
            }
        }

    def _get_innings(self, game_element):
        table = game_element.find_element(By.CLASS_NAME, "tScore")
        headers = [th.text for th in table.find_elements(By.TAG_NAME, "th")]
        rows = table.find_elements(By.TAG_NAME, "tr")

        innings_data = []
        for row in rows[1:]:
            cells = row.find_elements(By.TAG_NAME, "td")
            team_data = {
                "team": cells[0].text,
                "innings": {headers[i]: cells[i].text for i in range(1, 13)},
                "total": {
                    "R": cells[-4].text,
                    "H": cells[-3].text,
                    "E": cells[-2].text,
                    "B": cells[-1].text
                }
            }
            innings_data.append(team_data)
        return innings_data

    def _get_current_status(self, game_element):
        base_element = game_element.find_element(By.CLASS_NAME, "base")
        try:
            out_text = base_element.find_element(By.TAG_NAME, "p").text
            out_count = ''.join(filter(str.isdigit, out_text))
            outs = int(out_count) if out_count.isdigit() else 0
        except:
            outs = 0

        return {
            "current_inning": game_element.find_element(By.CLASS_NAME, "flag").text,
            "base_status": {
                "1st": self._check_base_status(base_element, "base1"),
                "2nd": self._check_base_status(base_element, "base2"),
                "3rd": self._check_base_status(base_element, "base3")
            },
            "outs": outs
        }

    def _check_base_status(self, element, class_name):
        img_src = element.find_element(By.CLASS_NAME, class_name).find_element(By.TAG_NAME, "img").get_attribute("src")
        return "occupied" if "base_on.png" in img_src else "empty"

    def _get_game_info(self, game_element):
        place_info = game_element.find_element(By.CLASS_NAME, "place").text.split()
        return {
            "stadium": place_info[0],
            "start_time": place_info[1]
        }

    def save_to_db(self, games):
        for game in games:
            # 1. 팀 저장
            away_id = self._get_or_create_team(game["teams"]["away"]["name"])
            home_id = self._get_or_create_team(game["teams"]["home"]["name"])

            # 2. 게임 저장
            self.cursor.execute("""
                INSERT INTO games (game_date, stadium, start_time, current_inning)
                VALUES (%s, %s, %s, %s)
            """, (
                datetime.now().date(),
                game["game_info"]["stadium"],
                game["game_info"]["start_time"],
                game["current_status"]["current_inning"]
            ))
            game_id = self.cursor.lastrowid

            # 3. 팀-게임 연결
            self._insert_game_team(game_id, away_id, False, game["teams"]["away"]["score"])
            self._insert_game_team(game_id, home_id, True, game["teams"]["home"]["score"])

            # 4. 이닝 스코어
            for team_data in game["innings"]:
                team_id = self._get_or_create_team(team_data["team"])
                for inning, score in team_data["innings"].items():
                    if score.isdigit():
                        self.cursor.execute("""
                            INSERT INTO innings (game_id, team_id, inning_number, score)
                            VALUES (%s, %s, %s, %s)
                        """, (game_id, team_id, int(inning), int(score)))

                total = team_data["total"]
                self.cursor.execute("""
                    INSERT INTO totals (game_id, team_id, runs, hits, errors, bb)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    game_id, team_id,
                    total["R"], total["H"], total["E"], total["B"]
                ))

            # 5. 경기 상태 저장
            base = game["current_status"]["base_status"]
            outs = game["current_status"]["outs"]
            self.cursor.execute("""
                INSERT INTO status (game_id, first_base_status, second_base_status, third_base_status, outs)
                VALUES (%s, %s, %s, %s, %s)
            """, (game_id, base["1st"], base["2nd"], base["3rd"], outs))

        self.db.commit()

    def _get_or_create_team(self, name):
        self.cursor.execute("SELECT team_id FROM teams WHERE team_name = %s", (name,))
        row = self.cursor.fetchone()
        if row:
            return row[0]
        self.cursor.execute("INSERT INTO teams (team_name) VALUES (%s)", (name,))
        return self.cursor.lastrowid

    def _insert_game_team(self, game_id, team_id, is_home, score):
        self.cursor.execute("""
            INSERT INTO game_teams (game_id, team_id, is_home, score)
            VALUES (%s, %s, %s, %s)
        """, (game_id, team_id, is_home, score))

    def close(self):
        if hasattr(self, 'cursor'):
            self.cursor.close()
        if hasattr(self, 'db'):
            self.db.close()
        if hasattr(self, 'driver'):
            self.driver.quit()

if __name__ == "__main__":
    crawler = KboScoreCrawler()
    try:
        score_data = crawler.get_scoreboard()
        crawler.save_to_db(score_data)
        print("DB 저장 성공")
    except Exception as e:
        print(f"오류 발생: {str(e)}")
    finally:
        crawler.close()

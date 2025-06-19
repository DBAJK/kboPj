import pandas as pd
import pymysql
import requests
from bs4 import BeautifulSoup as bs

url_base = 'https://www.koreabaseball.com/Record/Player/{category}'
category_list = [
    'HitterBasic/Basic1.aspx',
    'PitcherBasic/Basic1.aspx',
    'Defense/Basic.aspx',
    'Runner/Basic.aspx'
]

category_map = {
    'HitterBasic': 'Hitter',
    'PitcherBasic': 'Pitcher',
    'Defense': 'Defense',
    'Runner': 'Runner'
}

def get_connection():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='1234',
        db='kboPj',
        charset='utf8mb4',
        autocommit=True
    )

def map_team_name(korean_team_name):
    team_mapping = {
        '삼성': 10030,
        '롯데': 10050,
        'KIA': 10020,
        '한화': 10040,
        '두산': 10070,
        'LG': 10060,
        'NC': 10100,
        'KT': 10090,
        'SSG': 10080,
        '키움': 10010
    }
    return team_mapping.get(korean_team_name.strip(), None)

def get_value(row, key, dtype=str):
    val = row.get(key)
    if val in [None, '-', '']:
        return None
    try:
        return dtype(val)
    except:
        return None

def extract_table_data(soup):
    table = soup.find('table', class_='tData01')
    headers = []
    for th in table.find('thead').find_all('th'):
        if 'href' in str(th):
            sort_attr = th.find('a')
            if sort_attr:
                header = sort_attr['href'].split("'")[1]  # 'sort('HR_CN')'
            else:
                header = th.get_text(strip=True)
        else:
            header = th.get_text(strip=True)

        if '선수' in header:
            headers.append('Name')
        elif '팀' in header:
            headers.append('Team')
        elif '포지션' in header or '수비위치' in header:
            headers.append('POS_SC')
        elif '순위' in header:
            headers.append('Rank')
        else:
            headers.append(header)

    # 데이터 추출
    rows = []
    for tr in table.find('tbody').find_all('tr'):
        cols = [td.text.strip() for td in tr.find_all('td')]
        if len(cols) == len(headers):
            rows.append(dict(zip(headers, cols)))
    return rows

def insert_player_stats(df, record_type, conn):
    cursor = conn.cursor()

    for _, row in df.iterrows():
        name = get_value(row, 'Name')
        team_name = get_value(row, 'Team')
        team_id = map_team_name(team_name)
        position = get_value(row, 'POS_SC') or get_value(row, 'Position')
        player_rank = get_value(row, 'Rank', int)

        # 공통
        g = get_value(row, 'GAME_CN', int)

        # 기본값
        data = {
            # Hitter
            'AVG': None, 'PA': None, 'AB': None, 'R': None, 'H': None, 'H2': None, 'H3': None, 'HR': None, 'TB': None,
            'RBI': None, 'SAC': None, 'SF': None,

            # Pitcher
            'ERA': None, 'W': None, 'L': None, 'SV': None, 'HLD': None,
            'WPCT': None, 'TBF': None, 'IP': None, 'PH': None, 'PHR': None, 'PBB': None, 'PHBP': None,
            'PSO': None, 'PR': None, 'PER': None, 'WHIP': None,

            # Defense
            'GS': None, 'D_IP': None, 'E': None, 'PKO': None, 'PO': None, 'A': None, 
            'DP': None, 'FPCT': None, 'PB': None, 'DSB': None,
            'DCS': None, 'CS_RT': None,

            # Runner
            'SBA': None, 'SB2': None, 'CS2': None, 'SBP': None, 'OOB': None, 'PKO': None
        }

        if record_type == 'Hitter':
            data.update({
                'AVG': get_value(row, 'HRA_RT', float),
                'PA': get_value(row, 'PA_CN', int),
                'AB': get_value(row, 'AB_CN', int),
                'R': get_value(row, 'RUN_CN', int),
                'H': get_value(row, 'HIT_CN', int),
                'H2': get_value(row, 'H2_CN', int),
                'H3': get_value(row, 'H3_CN', int),
                'HR': get_value(row, 'HR_CN', int),
                'TB': get_value(row, 'TB_CN', int),
                'RBI': get_value(row, 'RBI_CN', int),
                'SAC': get_value(row, 'SH_CN', int),
                'SF': get_value(row, 'SF_CN', int)
            })

        elif record_type == 'Pitcher':
            data.update({
                'ERA': get_value(row, 'ERA_RT', float),
                'W': get_value(row, 'W_CN', int),
                'L': get_value(row, 'L_CN', int),
                'SV': get_value(row, 'SV_CN', int),
                'HLD': get_value(row, 'HOLD_CN', int),
                'WPCT': get_value(row, 'WRA_RT', float),
                'TBF': get_value(row, 'TBF_CN', int),
                'IP': get_value(row, 'INN2_CN'),
                'PH': get_value(row, 'HIT_CN', int),
                'PHR': get_value(row, 'HR_CN', int),
                'PBB': get_value(row, 'BB_CN', int),
                'PHBP': get_value(row, 'HP_CN', int),
                'PSO': get_value(row, 'KK_CN', int),
                'PR': get_value(row, 'R_CN', int),
                'PER': get_value(row, 'ER_CN', int),
                'WHIP': get_value(row, 'WHIP_RT', float)
            })


        elif record_type == 'Defense':
            data.update({
                'GS': get_value(row, 'START_GAME_CN', int),
                'D_IP': get_value(row, 'DEFEN_INN2_CN'),
                'E': get_value(row, 'ERR_CN', int),
                'PKO': get_value(row, 'POFF_CN', int),
                'PO': get_value(row, 'PO_CN', int),
                'A': get_value(row, 'ASS_CN', int),
                'DP': get_value(row, 'GDP_CN', int),
                'FPCT': get_value(row, 'FPCT_RT', float),
                'PB': get_value(row, 'PB_CN', int),
                'DSB': get_value(row, 'SB_CN', int),
                'DCS': get_value(row, 'CS_CN', int),
                'CS_RT': get_value(row, 'CS_RT', float)
            })

        elif record_type == 'Runner':
            data.update({
                'SBA': get_value(row, 'SBA_CN', int),
                'SB2': get_value(row, 'SB_CN', int),
                'CS2': get_value(row, 'CS_CN', int),
                'SBP': get_value(row, 'SB_RT', float),
                'OOB': get_value(row, 'RO_CN', int),
                'PKO': get_value(row, 'POFF_CN', int),
            })

        sql = """
        INSERT INTO player_stats (
            recordType, name, teamId, position, playerRank,
            G,
            AVG, PA, AB, R, H, H2, H3, HR, TB, RBI, SAC, SF,
            ERA, W, L, SV, HLD, WPCT, TBF, IP, PH, PHR, PBB, PHBP, PSO, PR, PER, WHIP,
            GS, D_IP, E, PKO, PO, A, DP, FPCT, PB, DSB, DCS, CS_RT,
            SBA, SB2, CS2, SBP, OOB
        ) VALUES (
            %s, %s, %s, %s, %s,
            %s,
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s
        )
        """
        values = (
            record_type, name, team_id, position, player_rank,
            g,
            data['AVG'], data['PA'], data['AB'], data['R'], data['H'], data['H2'], data['H3'], data['HR'], data['TB'], data['RBI'], data['SAC'], data['SF'],
            data['ERA'], data['W'], data['L'], data['SV'], data['HLD'], data['WPCT'], data['TBF'], data['IP'],
            data['PH'], data['PHR'], data['PBB'], data['PHBP'], data['PSO'], data['PR'], data['PER'], data['WHIP'],
            data['GS'], data['D_IP'], data['E'], data['PKO'], data['PO'], data['A'], data['DP'], data['FPCT'],
            data['PB'], data['DSB'], data['DCS'], data['CS_RT'],
            data['SBA'], data['SB2'], data['CS2'], data['SBP'], data['OOB']
        )

        try:
            cursor.execute(sql, values)
        except Exception as e:
            print(f"[ERROR] 삽입 실패: {e}")
            print(f"▶ recordType={record_type}, player={name}, values={values}")

    cursor.close()

def main():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE player_stats")
    print("기존 데이터 초기화 완료")

    for category in category_list:
        category_key = category.split('/')[0]
        record_type = category_map.get(category_key)
        if not record_type:
            print(f"[경고] 알 수 없는 카테고리: {category}")
            continue

        url = url_base.format(category=category)
        try:
            res = requests.get(url)
            soup = bs(res.text, 'html.parser')
            data_rows = extract_table_data(soup)
            if not data_rows:
                print(f"[{record_type}] 데이터 없음")
                continue

            df = pd.DataFrame(data_rows)
            insert_player_stats(df, record_type, conn)
            print(f"[{record_type}] {len(df)}건 삽입 완료")

        except Exception as e:
            print(f"[{record_type}] 크롤링 실패: {e}")

    conn.close()
    print("모든 데이터 삽입 완료")

if __name__ == '__main__':
    main()

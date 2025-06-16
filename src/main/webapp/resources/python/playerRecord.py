import pandas as pd
import pymysql
import requests
from bs4 import BeautifulSoup as bs

# 카테고리별 URL
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

# MySQL 연결 함수
def get_connection():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='1234',
        db='kboPj',
        charset='utf8mb4',
        autocommit=True
    )

# 안전한 값 추출 유틸
def get_value(row, key, default=None, dtype=str):
    val = row.get(key)
    if val is None or val == '-' or val == '':
        return default
    try:
        return dtype(val)
    except:
        return default

# DB에 삽입
def insert_player_stats(df, record_type, conn):
    cursor = conn.cursor()
    for _, row in df.iterrows():
        name = get_value(row, 'Name')
        raw_team_name = get_value(row, 'Team')
        teamID = map_team_name(raw_team_name)
        team = raw_team_name
        position = get_value(row, 'POS_SC') or get_value(row, 'Position')
        game_count = get_value(row, 'GAME_CN', dtype=float)

        # Hitter
        hitter_rank = get_value(row, 'Rank', dtype=int) if record_type == 'Hitter' else None
        hra_rt = get_value(row, 'HRA_RT', dtype=float) if record_type == 'Hitter' else None
        pa_cn = get_value(row, 'PA_CN', dtype=float) if record_type == 'Hitter' else None
        ab_cn = get_value(row, 'AB_CN', dtype=float) if record_type == 'Hitter' else None
        run_cn = get_value(row, 'RUN_CN', dtype=float) if record_type == 'Hitter' else None
        hit_cn = get_value(row, 'HIT_CN', dtype=float) if record_type == 'Hitter' else None
        hr_cn = get_value(row, 'HR_CN', dtype=float) if record_type == 'Hitter' else None
        rbi_cn = get_value(row, 'RBI_CN', dtype=float) if record_type == 'Hitter' else None

        # Pitcher
        pitcher_rank = get_value(row, 'Rank', dtype=int) if record_type == 'Pitcher' else None
        era_rt = get_value(row, 'ERA_RT', dtype=float) if record_type == 'Pitcher' else None
        inn2_cn = get_value(row, 'INN2_CN') if record_type == 'Pitcher' else None
        w_cn = get_value(row, 'W_CN', dtype=float) if record_type == 'Pitcher' else None
        l_cn = get_value(row, 'L_CN', dtype=float) if record_type == 'Pitcher' else None
        kk_cn = get_value(row, 'KK_CN', dtype=float) if record_type == 'Pitcher' else None

        # Defense
        defense_rank = get_value(row, 'Rank', dtype=int) if record_type == 'Defense' else None
        pos_sc = get_value(row, 'POS_SC') if record_type == 'Defense' else None
        defen_inn2_cn = get_value(row, 'DEFEN_INN2_CN') if record_type == 'Defense' else None
        err_cn = get_value(row, 'ERR_CN', dtype=float) if record_type == 'Defense' else None
        fpct_rt = get_value(row, 'FPCT_RT', dtype=float) if record_type == 'Defense' else None

        # Runner
        runner_rank = get_value(row, 'Rank', dtype=int) if record_type == 'Runner' else None
        sba_cn = get_value(row, 'SBA_CN', dtype=float) if record_type == 'Runner' else None
        sb_cn = get_value(row, 'SB_CN', dtype=float) if record_type == 'Runner' else None
        cs_cn = get_value(row, 'CS_CN', dtype=float) if record_type == 'Runner' else None
        sb_rt = get_value(row, 'SB_RT', dtype=float) if record_type == 'Runner' else None

        sql = """
        INSERT INTO player_stats
        (recordType, Name, teamID, Team, Position, GameCount,
            HitterRank, HRA_RT, PA_CN, AB_CN, RUN_CN, HIT_CN, HR_CN, RBI_CN,
            PitcherRank, ERA_RT, INN2_CN, W_CN, L_CN, KK_CN,
            DefenseRank, POS_SC, DEFEN_INN2_CN, ERR_CN, FPCT_RT,
            RunnerRank, SBA_CN, SB_CN, CS_CN, SB_RT)
        VALUES
        (%s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s)
        """

        values = (
            record_type, name, teamID, team, position, game_count,
            hitter_rank, hra_rt, pa_cn, ab_cn, run_cn, hit_cn, hr_cn, rbi_cn,
            pitcher_rank, era_rt, inn2_cn, w_cn, l_cn, kk_cn,
            defense_rank, pos_sc, defen_inn2_cn, err_cn, fpct_rt,
            runner_rank, sba_cn, sb_cn, cs_cn, sb_rt
        )
        cursor.execute(sql, values)
    cursor.close()

# 크롤링 및 삽입 실행
def main():
    conn = get_connection()
    cursor = conn.cursor()
    # 기존 데이터 삭제
    cursor.execute("TRUNCATE TABLE player_stats")
    print("기존 player_stats 테이블 데이터 삭제 완료")

    for category in category_list:
        record_type = category_map[category.split('/')[0]]
        url = url_base.format(category=category)
        req = requests.get(url)
        soup = bs(req.text, 'html.parser')

        temp_table = soup.find('div', {'class': 'record_result'})
        col_tag = temp_table.find_all('td')
        col_list = ['Rank', 'Name', 'Team']
        for col in col_tag:
            try:
                temp_value = col.attrs['data-id']
                if temp_value not in col_list:
                    col_list.append(temp_value)
                else:
                    break
            except:
                pass

        temp_data = pd.DataFrame(columns=col_list)
        i = 0
        index = 0
        col_len = len(col_list)
        while True:
            try:
                temp_data.loc[i] = [x.text.strip() for x in temp_table.find_all('td')[index:index + col_len]]
                i += 1
                index += col_len
            except:
                break

        insert_player_stats(temp_data, record_type, conn)
        print(f"{record_type} 데이터 삽입 완료")

    conn.close()
    print("모든 카테고리 데이터 삽입 완료")
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
    return team_mapping.get(korean_team_name, 'unknown')  # 매핑 실패 시 'unknown' 반환


if __name__ == '__main__':
    main()

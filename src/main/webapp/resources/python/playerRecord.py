import pandas as pd
import pymysql
import os
import glob

# DB 연결 함수
def get_connection():
    return pymysql.connect(
        host='localhost',
        user='root',         # DB 사용자명
        password='1234', # DB 비밀번호
        db='cproject',
        charset='utf8mb4',
        autocommit=True
    )

# 공통 컬럼 추출 함수
def get_value(row, key, default=None, dtype=str):
    val = row.get(key)
    if val is None or val == '-' or val == '':
        return default
    try:
        return dtype(val)
    except:
        return default

# 각 카테고리별 insert 함수
def insert_player_stats(df, record_type, conn):
    cursor = conn.cursor()
    for _, row in df.iterrows():
        # 공통 정보
        name = get_value(row, 'Name')
        team = get_value(row, 'Team')
        position = get_value(row, 'POS_SC') or get_value(row, 'Position')
        game_count = get_value(row, 'GAME_CN', dtype=float)

        # hitter
        hitter_rank = get_value(row, 'Rank', dtype=int)
        hra_rt = get_value(row, 'HRA_RT', dtype=float)
        pa_cn = get_value(row, 'PA_CN', dtype=float)
        ab_cn = get_value(row, 'AB_CN', dtype=float)
        run_cn = get_value(row, 'RUN_CN', dtype=float)
        hit_cn = get_value(row, 'HIT_CN', dtype=float)
        hr_cn = get_value(row, 'HR_CN', dtype=float)
        rbi_cn = get_value(row, 'RBI_CN', dtype=float)

        # pitcher
        pitcher_rank = get_value(row, 'Rank', dtype=int)
        era_rt = get_value(row, 'ERA_RT', dtype=float)
        inn2_cn = get_value(row, 'INN2_CN')
        w_cn = get_value(row, 'W_CN', dtype=float)
        l_cn = get_value(row, 'L_CN', dtype=float)
        kk_cn = get_value(row, 'KK_CN', dtype=float)

        # defense
        defense_rank = get_value(row, 'Rank', dtype=int)
        pos_sc = get_value(row, 'POS_SC')
        defen_inn2_cn = get_value(row, 'DEFEN_INN2_CN')
        err_cn = get_value(row, 'ERR_CN', dtype=float)
        fpct_rt = get_value(row, 'FPCT_RT', dtype=float)

        # runner
        runner_rank = get_value(row, 'Rank', dtype=int)
        sba_cn = get_value(row, 'SBA_CN', dtype=float)
        sb_cn = get_value(row, 'SB_CN', dtype=float)
        cs_cn = get_value(row, 'CS_CN', dtype=float)
        sb_rt = get_value(row, 'SB_RT', dtype=float)

        sql = """
        INSERT INTO player_stats
        (recordType, Name, Team, Position, GameCount, HitterRank, HRA_RT, PA_CN, AB_CN, RUN_CN, HIT_CN, HR_CN, RBI_CN,
         PitcherRank, ERA_RT, INN2_CN, W_CN, L_CN, KK_CN,
         DefenseRank, POS_SC, DEFEN_INN2_CN, ERR_CN, FPCT_RT,
         RunnerRank, SBA_CN, SB_CN, CS_CN, SB_RT)
        VALUES
        (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
         %s, %s, %s, %s, %s, %s,
         %s, %s, %s, %s, %s,
         %s, %s, %s, %s, %s)
        """
        values = (
            record_type, name, team, position, game_count,
            hitter_rank if record_type == 'Hitter' else None,
            hra_rt if record_type == 'Hitter' else None,
            pa_cn if record_type == 'Hitter' else None,
            ab_cn if record_type == 'Hitter' else None,
            run_cn if record_type == 'Hitter' else None,
            hit_cn if record_type == 'Hitter' else None,
            hr_cn if record_type == 'Hitter' else None,
            rbi_cn if record_type == 'Hitter' else None,
            pitcher_rank if record_type == 'Pitcher' else None,
            era_rt if record_type == 'Pitcher' else None,
            inn2_cn if record_type == 'Pitcher' else None,
            w_cn if record_type == 'Pitcher' else None,
            l_cn if record_type == 'Pitcher' else None,
            kk_cn if record_type == 'Pitcher' else None,
            defense_rank if record_type == 'Defense' else None,
            pos_sc if record_type == 'Defense' else None,
            defen_inn2_cn if record_type == 'Defense' else None,
            err_cn if record_type == 'Defense' else None,
            fpct_rt if record_type == 'Defense' else None,
            runner_rank if record_type == 'Runner' else None,
            sba_cn if record_type == 'Runner' else None,
            sb_cn if record_type == 'Runner' else None,
            cs_cn if record_type == 'Runner' else None,
            sb_rt if record_type == 'Runner' else None
        )
        cursor.execute(sql, values)
    cursor.close()

def main():
    conn = get_connection()
    category_map = {
        'hitterbasic.json': 'Hitter',
        'pitcherbasic.json': 'Pitcher',
        'defense.json': 'Defense',
        'runner.json': 'Runner'
    }
    base_path = './app/player_record'
    for filename, record_type in category_map.items():
        filepath = os.path.join(base_path, filename)
        if os.path.exists(filepath):
            df = pd.read_json(filepath)
            insert_player_stats(df, record_type, conn)
            print(f"{filename} → {record_type} 데이터 삽입 완료")
        else:
            print(f"{filename} 파일이 존재하지 않습니다.")
    conn.close()
    print("모든 카테고리 데이터 삽입 완료")

if __name__ == '__main__':
    main()

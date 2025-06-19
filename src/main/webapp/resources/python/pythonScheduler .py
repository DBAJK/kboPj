from apscheduler.schedulers.blocking import BlockingScheduler
import subprocess

def run_scripts():
    subprocess.run(["python", "D:/workspace/kboPj/src/main/webapp/resources/python/playerRecord.py"])
    subprocess.run(["python", "D:/workspace/kboPj/src/main/webapp/resources/python/scoreBoard.py"])

scheduler = BlockingScheduler()

# cron 표현식 기반
scheduler.add_job(run_scripts, 'cron', hour=18, minute=0)    # 오후 6시
scheduler.add_job(run_scripts, 'cron', hour=23, minute=50)   # 오후 11시 50분

print("스케줄러 시작됨...")
scheduler.start()

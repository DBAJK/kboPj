import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;

@Component
public class PythonExecutor {

    // 매일 오후 6시에 실행
    @Scheduled(cron = "0 0 18 * * *")
    public void runAt6PM() {
        System.out.println("[Scheduler] 오후 6시 실행 시작");
        runScript("src/main/webapp/resources/python/playerRecord.py");
        runScript("src/main/webapp/resources/python/scoreBoard.py");
    }

    // 매일 오후 11시 50분에 실행
    @Scheduled(cron = "0 50 23 * * *")
    public void runAt1150PM() {
        System.out.println("[Scheduler] 오후 11시 50분 실행 시작");
        runScript("src/main/webapp/resources/python/playerRecord.py");
        runScript("src/main/webapp/resources/python/scoreBoard.py");
    }

    // 파이썬 스크립트 실행 로직
    public void runScript(String scriptPath) {
        try {
            // 로컬 개발환경에서는 python 또는 python3 경로를 명확히 설정해야 할 수도 있음
            ProcessBuilder pb = new ProcessBuilder("python", scriptPath);
            pb.redirectErrorStream(true);

            Process process = pb.start();

            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()))) {

                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("[Python Output] " + line);
                }
            }

            int exitCode = process.waitFor();
            System.out.println("[PythonExecutor] 종료 코드: " + exitCode);

        } catch (Exception e) {
            System.err.println("[PythonExecutor] 예외 발생");
            e.printStackTrace();
        }
    }
}

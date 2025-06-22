package com.pj.kboPj.util;

import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.BufferedReader;
import java.io.InputStreamReader;

@Component
public class PythonStartupRunner {

    private final String pythonBasePath = "D:\\project\\kboPj\\src\\main\\webapp\\resources\\python\\";
    private final String[] pythonScripts = {
            "playerRecord.py",
            "scoreBoard.py"
    };

    @PostConstruct
    public void runOnStartup() {
        System.out.println("🔁 서버 기동 시 Python 스크립트 실행 시작");
        for (String script : pythonScripts) {
            try {
                String fullPath = pythonBasePath + script;
                ProcessBuilder pb = new ProcessBuilder("python", fullPath);
                pb.redirectErrorStream(true);
                Process process = pb.start();

                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("[" + script + "] Python Output: " + line);
                }

                int exitCode = process.waitFor();
                System.out.println("[" + script + "] Python exited with code: " + exitCode);

                if (exitCode != 0) {
                    System.err.println("[" + script + "] 실행 실패! 종료 코드: " + exitCode);
                }
            } catch (Exception e) {
                System.err.println("[" + script + "] 실행 중 예외 발생:");
                e.printStackTrace();
            }
        }
        System.out.println("✅ Python 스크립트 자동 실행 완료");
    }
}

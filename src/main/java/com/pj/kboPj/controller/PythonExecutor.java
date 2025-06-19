import java.io.BufferedReader;
import java.io.InputStreamReader;

public class PythonExecutor {
    private final PythonExecutor executor = new PythonExecutor();

    public void runScript(String scriptPath) {
        try {
            ProcessBuilder pb = new ProcessBuilder("python", scriptPath);
            pb.redirectErrorStream(true); // stderr도 stdout에 포함
            Process process = pb.start();

            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()))) {

                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("[Python Output] " + line);
                }
            }

            int exitCode = process.waitFor();
            System.out.println("스크립트 종료 코드: " + exitCode);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

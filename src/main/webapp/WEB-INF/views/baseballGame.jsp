<%--
  Created by IntelliJ IDEA.
  User: jgkim
  Date: 2025-06-12
  Time: 오후 9:19
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>

<link href="/resources/css/kboScore.css" rel="stylesheet" type="text/css">
<div class="game-body">
<div class="game-container">
    <h1>숫자 야구</h1>
    <p class="subtitle">3자리 숫자를 맞춰보세요!</p>

    <div class="input-section">
        <input type="text" id="guessInput" class="guessInput" placeholder="123" maxlength="3">
        <button class="guess-btn" onclick="makeGuess()">추측하기</button>
    </div>

    <div class="game-info">
        <div class="info-item">
            <div class="info-label">시도 횟수</div>
            <div class="info-value" id="attempts">0</div>
        </div>
        <div class="info-item">
            <div class="info-label">최고 기록</div>
            <div class="info-value" id="bestScore">-</div>
        </div>
    </div>

    <button class="new-game-btn" onclick="newGame()">새 게임</button>

    <div id="message"></div>
    <div id="errorMessage" class="error-message"></div>

    <div class="history" id="history"></div>

    <div class="rules">
        <h3>게임 규칙</h3>
        <p><strong>스트라이크:</strong> 숫자와 위치가 모두 맞음</p>
        <p><strong>볼:</strong> 숫자는 맞지만 위치가 틀림</p>
        <p><strong>아웃:</strong> 맞는 숫자가 없음</p>
        <p>• 서로 다른 3자리 숫자를 입력하세요</p>
        <p>• 3스트라이크가 되면 성공!</p>
    </div>
</div>
</div>
<script>
    let targetNumber = '';
    let attempts = 0;
    let gameHistory = [];
    let bestScore = localStorage.getItem('bestScore') || null;

    // 페이지 로드 시 초기화
    document.addEventListener('DOMContentLoaded', function() {
        newGame();
        updateBestScore();

        // 엔터키로 추측하기
        document.getElementById('guessInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                makeGuess();
            }
        });
    });

    function generateTargetNumber() {
        let numbers = [];
        while (numbers.length < 3) {
            let digit = Math.floor(Math.random() * 10);
            if (!numbers.includes(digit)) {
                numbers.push(digit);
            }
        }
        return numbers.join('');
    }

    function validateInput(guess) {
        if (guess.length !== 3) {
            return '3자리 숫자를 입력해주세요.';
        }

        if (!/^\d+$/.test(guess)) {
            return '숫자만 입력해주세요.';
        }

        let digits = guess.split('');
        if (new Set(digits).size !== 3) {
            return '서로 다른 숫자를 입력해주세요.';
        }

        return null;
    }

    function calculateResult(guess, target) {
        let strikes = 0;
        let balls = 0;

        for (let i = 0; i < 3; i++) {
            if (guess[i] === target[i]) {
                strikes++;
            } else if (target.includes(guess[i])) {
                balls++;
            }
        }

        return { strikes, balls };
    }

    function makeGuess() {
        const guessInput = document.getElementById('guessInput');
        const guess = guessInput.value.trim();
        const errorElement = document.getElementById('errorMessage');

        // 입력 검증
        const error = validateInput(guess);
        if (error) {
            errorElement.textContent = error;
            return;
        }

        errorElement.textContent = '';
        attempts++;

        const result = calculateResult(guess, targetNumber);
        const historyItem = {
            guess: guess,
            strikes: result.strikes,
            balls: result.balls,
            attempt: attempts
        };

        gameHistory.push(historyItem);
        updateHistory();
        updateAttempts();

        if (result.strikes === 3) {
            // 게임 성공
            showSuccessMessage();
            updateBestScore();
            guessInput.disabled = true;
        }

        guessInput.value = '';
        guessInput.focus();
   }

    function calculatePoint(attempts) {
        if (attempts <= 3) return 1000;
        if (attempts <= 5) return 500;
        return 100;
    }

    function showSuccessMessage() {
        const messageDiv = document.getElementById('message');
        const point = calculatePoint(attempts);
        const userName = '<c:out value="${sessionScope.userName}" default=""/>';
        const userPointStr = '<c:out value="${sessionScope.userPoint}" default="0"/>';
        const userPoint = parseInt(userPointStr, 10);
        const totalPoint = point + userPoint;
        if(userName != null && userName != '' ){
            messageDiv.innerHTML = `
                <div class="success-message">
                    축하합니다! ${'${attempts}'}번 만에 맞추셨습니다!<br>
                    정답: ${'${targetNumber}'}<br>
                    🎁 획득한 포인트: <strong>${'${point}'}점</strong><br>
                    총 포인트: ${'${totalPoint}'}포인트
                </div>
            `;
        }else{
            messageDiv.innerHTML = `
                <div class="success-message">
                    축하합니다! ${'${attempts}'}번 만에 맞추셨습니다!<br>
                    정답: ${'${targetNumber}'}<br>
                </div>
            `;
            return;
        }

        $.ajax({
            type: "POST",
            url: "/service/updatePoint",
            data: {
                point: totalPoint
            },
            success: function(response) {
                console.log("포인트 업데이트 성공:", response);
                document.querySelector(".dropdown-menu .user-point").innerText = totalPoint;
            },
            error: function(xhr, status, error) {
                console.error("포인트 업데이트 실패:", error);
            }
        });
    }

    function updateHistory() {
        const historyDiv = document.getElementById('history');
        const latest = gameHistory[gameHistory.length - 1];

        let resultText = '';
        if (latest.strikes === 3) {
            resultText = '<span class="strike">3 스트라이크! 🎉</span>';
        } else if (latest.strikes === 0 && latest.balls === 0) {
            resultText = '아웃 ⚾';
        } else {
            let parts = [];
            if (latest.strikes > 0) parts.push(`<span class="strike">${'${latest.strikes}'}S</span>`);
            if (latest.balls > 0) parts.push(`<span class="ball">${'${latest.balls}'}B</span>`);
            resultText = parts.join(' ');
        }

        const historyItem = document.createElement('div');
        historyItem.className = 'history-item';
        historyItem.innerHTML = `
                <span class="guess-number">${'${latest.attempt}'}. ${'${latest.guess}'}</span>
                <span class="result">${'${resultText}'}</span>
            `;

        historyDiv.appendChild(historyItem);
        historyDiv.scrollTop = historyDiv.scrollHeight;
    }

    function updateAttempts() {
        document.getElementById('attempts').textContent = attempts;
    }

    function updateBestScore() {
        const bestScoreElement = document.getElementById('bestScore');
        if (bestScore) {
            bestScoreElement.textContent = bestScore + '번';
        }

        // 게임 완료 시 최고 기록 업데이트
        if (gameHistory.length > 0 && gameHistory[gameHistory.length - 1].strikes === 3) {
            if (!bestScore || attempts < parseInt(bestScore)) {
                bestScore = attempts;
                localStorage.setItem('bestScore', bestScore);
                bestScoreElement.textContent = bestScore + '번';
            }
        }
    }

    function newGame() {
        targetNumber = generateTargetNumber();
        attempts = 0;
        gameHistory = [];

        document.getElementById('guessInput').disabled = false;
        document.getElementById('guessInput').value = '';
        document.getElementById('guessInput').focus();
        document.getElementById('message').innerHTML = '';
        document.getElementById('errorMessage').textContent = '';
        document.getElementById('history').innerHTML = '';

        updateAttempts();

        console.log('새 게임 시작! 정답:', targetNumber); // 개발용 (실제 게임에서는 제거)
    }
</script>

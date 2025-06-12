<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link href="/resources/css/main.css" rel="stylesheet" type="text/css">

<div id="header" class="header">
    <div class="header-left">
        <div class="logo-circle">K</div>
        <span class="logo-text">KBO Board</span>
    </div>

    <div class="header-right" id="user-section">
        <!-- 로그인 상태에 따라 동적 렌더링 -->
    </div>
</div>

<script>
    // JSP에서 세션 값 전달
    const userName = '<c:out value="${sessionScope.userName}" default="" />';
    const isLoggedIn = userName !== '';

    const userSection = document.getElementById('user-section');
    if (isLoggedIn) {
        userSection.innerHTML = `
            <div class="user-dropdown">
                <span class="dropdown-toggle"><span class="user-name">\${userName}  ▼</span></span>
                <div class="dropdown-menu" style="display: none;">
                    <a href="/myPage" class="dropdown-item">마이페이지</a>
                    <a href="/logout" class="dropdown-item">로그아웃</a>
                </div>
            </div>
        `;
    } else {
        userSection.innerHTML = `
            <button class="login-button-header" onclick="location.href='/loginForm'">로그인</button>
        `;
    }
    // 이벤트 위임 방식 사용
    document.addEventListener("click", function(e) {
        const toggle = document.querySelector('.dropdown-toggle');
        const menu = document.querySelector('.dropdown-menu');
        if (!toggle || !menu) return;

        if (toggle.contains(e.target)) {
            // 토글 누르면 메뉴 보이기/숨기기
            menu.style.display = (menu.style.display === 'block') ? 'none' : 'block';
        } else if (!menu.contains(e.target)) {
            // 바깥 클릭 시 닫기
            menu.style.display = 'none';
        }
    });

    document.querySelector('.header-left').onclick = function() {
        window.location.href = '/mainForm';
    };
</script>

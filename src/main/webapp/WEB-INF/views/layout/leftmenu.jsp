<!-- /layout/leftmenu.jsp -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link href="/resources/css/main.css" rel="stylesheet" type="text/css">

<div id="leftmenu" class="leftmenu">
    <div>
        <span class="menu-title">Menu</span>
    </div>
    <div class="menu-item" data-path="/mainForm">
        <a href="/mainForm" class="menu-link">기록실</a>
    </div>
    <div class="menu-item" data-path="/scoreBoard">
        <a href="/scoreBoard" class="menu-link">스코어보드</a>
    </div>
    <div class="menu-item" data-path="/baseballGame">
        <a href="/baseballGame" class="menu-link">숫자 야구 게임</a>
    </div>
    <div class="menu-item" data-path="/fanBulletinBoard">
        <a href="/fanBulletinBoard" class="menu-link">팬게시판</a>
    </div>

</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const urlParams = new URLSearchParams(window.location.search);
        const formType = urlParams.get("formType");

        if (!formType) return;

        document.querySelectorAll('.menu-item').forEach(item => {
            const path = item.getAttribute('data-path');
            if (path.includes(formType)) {
                const link = item.querySelector('.menu-link');
                link.classList.add('active');
            }
        });
    });
</script>

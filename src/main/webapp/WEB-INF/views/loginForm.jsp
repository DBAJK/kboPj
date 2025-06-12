<%--
  Created by IntelliJ IDEA.
  User: jgkim
  Date: 2025-05-13
  Time: 오후 7:39
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<link href="/resources/css/main.css" rel="stylesheet" type="text/css">
<body>
    <!-- 로그인 폼 영역 -->
    <div style="width:600px; text-align:center;">
        <h1 style="color:#4a5cc6; font-size: 70px">LOGIN</h1>
        <form id="loginForm" class="loginForm" name="loginForm" method="post">
            <input type="text" id="userId" name="userId" placeholder="ID" /><br/>
            <input type="password" id="userPw" name="userPw" placeholder="PASSWORD" /><br/>
            <div style="margin-bottom:20px; color:#888;">
                <a href="joinForm" >회원가입</a>
            </div>
            <button type="button" onclick="loginChk();" class="login-button">Login</button>
        </form>
    </div>
</body>
<script type="text/javascript" >
    function loginChk(){
        var params =$("#loginForm").serialize();
        console.log(params);
        $.ajax({
            type : "post",
            url : "/service/loginForm",
            data : params,
            success : function(data){
                if(data == "loginOk"){
                    location.href = '/mainForm';
                } else {
                    alert("로그인에 실패하였습니다.\nID와 비밀번호를 확인해주세요.");
                }
            },
            error : function(request, status, error){
                console.log(request.status);
                console.log(error);
            }
        });
    }

</script>

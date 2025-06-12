<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<link href="/resources/css/main.css" rel="stylesheet" type="text/css">
<div class="contentArea">
    <div class="headerArea">
        <span>마이페이지</span>
        <div class="btnPanel">
            <button type="button" id="btnSave">계정 변경</button>
            <button type="button" id="btnDel">취소</button><br>
        </div>
    </div>
    <form id="joinForm" class="joinForm" name="joinForm" method="post">
        <p>아이디</p><input type="text" name="userId" id="userId">
        <p>비밀번호</p> <input type="password" name="userPw" id="userPw" placeholder="변경할 비밀번호 입력(문자, 숫자, 특수문자 포함 8~20자)"><br>
        <p>비밀번호 확인</p> <input type="password" name="userPwChk" id="userPwChk" placeholder="변경할 비밀번호 재입력"><br>

        <p>이름</p> <input type="text" name="userName" id="userName" placeholder="변경할 이름을 입력해주세요."><br>
        <p>전화번호</p> <input type="tel" name="telNo" id="telNo" ><br>
        <p>생년월일</p> <input type="text" name="birtyD" id="birtyD" ><br>
        <p>사용자 포인트</p> <input type="text" name="userPoint" id="userPoint"><br>
    </form>

</div>
<script>
    $(document).ready(function () {
        $.ajax({
            url: "/myPageInfo",
            type: "GET",
            dataType: "json",
            success: function (res) {
                if (res.status === "success") {
                    $("#userId").val(res.userId).prop("readonly", true);
                    $("#userName").val(res.userName);
                    $("#telNo").val(res.phone).prop("readonly", true);
                    $("#birtyD").val(res.birthday).prop("readonly", true);
                    $("#userPoint").val(res.point).prop("readonly", true);
                    // 패스워드는 서버에서 보통 내려주지 않으므로 빈 채로 둡니다.
                } else {
                    alert("사용자 정보를 불러오지 못했습니다.");
                    location.href = "/mainForm";
                }
            },
            error: function (err) {
                console.error("에러 발생:", err);
                alert("서버 오류가 발생했습니다.");
            }
        });
        // 계정 변경 저장
        $("#btnSave").click(function(){
            if (joinForm.userPw.value !== joinForm.userPwChk.value) {
                alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
                $("#userPwChk").focus();
                return false;
            }
            if (confirm("비밀번호/이름을 변경 하시겠습니까?")) {
                var params = $("#joinForm").serialize();
                console.log(params);
                $.ajax({
                    url: '/updateUsersInfo',
                    data: params,
                    type: 'POST',
                    success: function(data) {
                        alert("계정이 업데이트 되었습니다.");
                        location.href = "/mainForm";
                    },
                    error: function(request, status, error) {
                        console.log("code: " + request.status);
                        console.log("message: " + request.responseText);
                        console.log("error: " + error);
                    }
                });
            } else {
                alert("다시 확인해주세요.");
            }
        });

        // 취소 버튼
        $("#btnDel").click(function() {
            if (confirm("로그인 화면으로 돌아가겠습니까?")) {
                location.href = '/mainForm';
            }
        });

    });
</script>

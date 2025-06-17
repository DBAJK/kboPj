<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String mode = request.getParameter("mode");
    if (mode == null) mode = "list";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>팬 게시판</title>
    <style>
        body {
            font-family: 'Malgun Gothic', sans-serif;
            margin: 20px;
            line-height: 1.6;
        }

        h1, h2 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }

        table th, table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }

        table th {
            background-color: #f4f4f4;
            font-weight: bold;
        }

        table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        table tr:hover {
            background-color: #f5f5f5;
        }

        .btn {
            display: inline-block;
            padding: 8px 16px;
            margin: 5px;
            text-decoration: none;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .btn:hover {
            background-color: #0056b3;
        }

        .btn-danger {
            background-color: #dc3545;
        }

        .btn-danger:hover {
            background-color: #c82333;
        }

        .btn-secondary {
            background-color: #6c757d;
        }

        .btn-secondary:hover {
            background-color: #545b62;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }

        .form-group input[type="text"],
        .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .form-group textarea {
            resize: vertical;
            min-height: 200px;
        }

        .post-header {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .post-content {
            background-color: #fff;
            padding: 20px;
            border: 1px solid #e9ecef;
            border-radius: 5px;
            margin-bottom: 20px;
            min-height: 200px;
        }

        .action-buttons {
            text-align: right;
            margin-top: 20px;
        }

        .meta-info {
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>

<!-- 목록 화면 -->
<c:if test="${param.mode == 'list' || empty param.mode}">
    <h1>팬 게시판 목록</h1>

    <div style="text-align: right; margin-bottom: 20px;">
        <a href="fanBulletinBoardDtl?mode=write" class="btn">글 작성</a>
    </div>

    <table>
        <thead>
        <tr>
            <th style="width: 80px;">번호</th>
            <th>제목</th>
            <th style="width: 120px;">작성자</th>
            <th style="width: 120px;">작성일</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${not empty boardList}">
                <c:forEach var="board" items="${boardList}">
                    <tr>
                        <td style="text-align: center;">${board.boardId}</td>
                        <td>
                            <a href="fanBulletinBoardDtl?id=${board.boardId}&mode=view"
                               style="text-decoration: none; color: #007bff;">${board.title}</a>
                        </td>
                        <td>${board.author}</td>
                        <td><fmt:formatDate value="${board.regDate}" pattern="yyyy-MM-dd"/></td>
                    </tr>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <tr>
                    <td colspan="4" style="text-align: center; color: #666; padding: 40px;">
                        등록된 게시글이 없습니다.
                    </td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</c:if>

<!-- 상세 보기 화면 -->
<c:if test="${param.mode == 'view'}">
    <h1>게시글 상세</h1>

    <div class="post-header">
        <h2 style="margin: 0 0 10px 0;">${board.title}</h2>
        <div class="meta-info">
            <span>작성자: <strong>${board.author}</strong></span> |
            <span>작성일: <fmt:formatDate value="${board.regDate}" pattern="yyyy-MM-dd HH:mm"/></span>
            <c:if test="${not empty board.modDate}">
                | <span>수정일: <fmt:formatDate value="${board.modDate}" pattern="yyyy-MM-dd HH:mm"/></span>
            </c:if>
        </div>
    </div>

    <div class="post-content">
        <div style="white-space: pre-wrap;">${board.content}</div>
    </div>

    <div class="action-buttons">
        <a href="fanBulletinBoardDtl?mode=list" class="btn btn-secondary">목록으로</a>

        <c:if test="${sessionScope.userId == board.authorId}">
            <a href="fanBulletinBoardDtl?id=${board.boardId}&mode=edit" class="btn">수정</a>
            <button onclick="confirmDelete(${board.boardId})" class="btn btn-danger">삭제</button>
        </c:if>
    </div>
</c:if>

<!-- 작성 및 수정 화면 -->
<c:if test="${param.mode == 'write' || param.mode == 'edit'}">
    <h1>
        <c:choose>
            <c:when test="${param.mode == 'write'}">글 작성</c:when>
            <c:otherwise>글 수정</c:otherwise>
        </c:choose>
    </h1>

    <form method="post" action="${param.mode == 'edit' ? 'updateBoard.do' : 'insertBoard.do'}" onsubmit="return validateForm()">
        <c:if test="${param.mode == 'edit'}">
            <input type="hidden" name="id" value="${board.boardId}">
        </c:if>

        <div class="form-group">
            <label for="title">제목 <span style="color: red;">*</span></label>
            <input type="text" id="title" name="title" value="${board.title}" required maxlength="100"
                   placeholder="제목을 입력하세요">
        </div>

        <div class="form-group">
            <label for="author">작성자</label>
            <input type="text" id="author" name="author" value="${sessionScope.userName}" readonly
                   style="background-color: #f8f9fa;">
        </div>

        <div class="form-group">
            <label for="content">내용 <span style="color: red;">*</span></label>
            <textarea id="content" name="content" required placeholder="내용을 입력하세요">${board.content}</textarea>
        </div>

        <div class="action-buttons">
            <a href="fanBulletinBoardDtl?mode=${param.mode == 'edit' ? 'view&id=' += board.boardId : 'list'}"
               class="btn btn-secondary">취소</a>
            <button type="submit" class="btn">
                <c:choose>
                    <c:when test="${param.mode == 'edit'}">수정 완료</c:when>
                    <c:otherwise>작성 완료</c:otherwise>
                </c:choose>
            </button>
        </div>
    </form>
</c:if>

<script>
    // 삭제 확인 함수
    function confirmDelete(boardId) {
        if (confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
            // 삭제 처리를 위한 폼 생성 및 전송
            var form = document.createElement('form');
            form.method = 'post';
            form.action = 'deleteBoard.do';

            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'id';
            input.value = boardId;

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
    }

    // 폼 유효성 검사
    function validateForm() {
        var title = document.getElementById('title').value.trim();
        var content = document.getElementById('content').value.trim();

        if (title === '') {
            alert('제목을 입력하세요.');
            document.getElementById('title').focus();
            return false;
        }

        if (content === '') {
            alert('내용을 입력하세요.');
            document.getElementById('content').focus();
            return false;
        }

        if (title.length > 100) {
            alert('제목은 100자 이내로 입력하세요.');
            document.getElementById('title').focus();
            return false;
        }

        return true;
    }

    // 페이지 로드 시 실행
    document.addEventListener('DOMContentLoaded', function() {
        // 목록에서 제목 링크에 호버 효과
        var titleLinks = document.querySelectorAll('table tbody a');
        titleLinks.forEach(function(link) {
            link.addEventListener('mouseenter', function() {
                this.style.textDecoration = 'underline';
            });
            link.addEventListener('mouseleave', function() {
                this.style.textDecoration = 'none';
            });
        });
    });
</script>

</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>팬 게시판 - ${mode == 'write' ? '글 작성' : mode == 'edit' ? '글 수정' : '글 보기'}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Malgun Gothic', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 20px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 1.8em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            margin: 0 5px;
        }
        
        .btn-secondary {
            background: #95a5a6;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #7f8c8d;
            transform: translateY(-2px);
        }
        
        .content-area {
            padding: 30px;
        }
        
        /* 조회 모드 스타일 */
        .view-mode .post-header {
            border-bottom: 3px solid #3498db;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        
        .view-mode .post-title {
            font-size: 2em;
            color: #2c3e50;
            margin-bottom: 15px;
            line-height: 1.4;
        }
        
        .view-mode .post-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .view-mode .post-meta .left {
            display: flex;
            gap: 20px;
        }
        
        .view-mode .post-content {
            font-size: 16px;
            line-height: 1.8;
            color: #2c3e50;
            min-height: 200px;
            margin-bottom: 30px;
            white-space: pre-wrap;
        }
        
        .view-mode .post-actions {
            text-align: center;
            padding: 20px 0;
            border-top: 2px solid #ecf0f1;
        }
        
        /* 작성/수정 모드 스타일 */
        .edit-mode .form-group {
            margin-bottom: 20px;
        }
        
        .edit-mode .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
        }
        
        .edit-mode .form-group input,
        .edit-mode .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .edit-mode .form-group input:focus,
        .edit-mode .form-group textarea:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 10px rgba(52, 152, 219, 0.3);
        }
        
        .edit-mode .form-group textarea {
            height: 300px;
            resize: vertical;
            font-family: inherit;
        }
        
        .edit-mode .form-actions {
            text-align: center;
            padding: 20px 0;
            border-top: 2px solid #ecf0f1;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #27ae60, #229954);
            color: white;
        }
        
        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.4);
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
        }
        
        .btn-danger:hover {
            background: linear-gradient(135deg, #c0392b, #a93226);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(231, 76, 60, 0.4);
        }
        
        .btn-warning {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white;
        }
        
        .btn-warning:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(243, 156, 18, 0.4);
        }
        
        /* 댓글 영역 */
        .comments-section {
            margin-top: 40px;
            border-top: 3px solid #ecf0f1;
            padding-top: 30px;
        }
        
        .comments-header {
            font-size: 1.3em;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 20px;
        }
        
        .comment-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 15px;
            border-left: 4px solid #3498db;
        }
        
        .comment-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 13px;
            color: #7f8c8d;
        }
        
        .comment-content {
            color: #2c3e50;
            line-height: 1.6;
        }
        
        .comment-form {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }
        
        .comment-form textarea {
            width: 100%;
            height: 80px;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 8px;
            resize: none;
            margin-bottom: 10px;
        }
        
        /* 모달 스타일 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        
        .modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 30px;
            border-radius: 10px;
            width: 400px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        
        .modal h3 {
            color: #e74c3c;
            margin-bottom: 15px;
        }
        
        .modal p {
            margin-bottom: 20px;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>
                <c:choose>
                    <c:when test="${mode == 'write'}">✏️ 새 글 작성</c:when>
                    <c:when test="${mode == 'edit'}">📝 글 수정</c:when>
                    <c:otherwise>📄 글 보기</c:otherwise>
                </c:choose>
            </h1>
            <a href="board-list.jsp" class="btn btn-secondary">← 목록으로</a>
        </div>
        
        <div class="content-area">
            <c:choose>
                <%-- 조회 모드 --%>
                <c:when test="${mode == 'view' || empty mode}">
                    <div class="view-mode">
                        <div class="post-header">
                            <h2 class="post-title">${board.title}</h2>
                            <div class="post-meta">
                                <div class="left">
                                    <span><strong>작성자:</strong> ${board.author}</span>
                                    <span><strong>작성일:</strong> 
                                        <fmt:formatDate value="${board.regDate}" pattern="yyyy-MM-dd HH:mm"/>
                                    </span>
                                    <c:if test="${board.modDate != null}">
                                        <span><strong>수정일:</strong> 
                                            <fmt:formatDate value="${board.modDate}" pattern="yyyy-MM-dd HH:mm"/>
                                        </span>
                                    </c:if>
                                </div>
                                <div class="right">
                                    <span><strong>조회수:</strong> ${board.viewCount}</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="post-content">
                            ${board.content}
                        </div>
                        
                        <div class="post-actions">
                            <%-- 작성자만 수정/삭제 가능 --%>
                            <c:if test="${sessionScope.userId == board.authorId}">
                                <a href="board-dtl.jsp?id=${board.id}&mode=edit" class="btn btn-warning">수정</a>
                                <button onclick="confirmDelete()" class="btn btn-danger">삭제</button>
                            </c:if>
                            <a href="board-list.jsp" class="btn btn-primary">목록</a>
                        </div>
                        
                        <%-- 댓글 영역 --%>
                        <div class="comments-section">
                            <div class="comments-header">
                                💬 댓글 <span style="color: #3498db;">${commentCount}</span>개
                            </div>
                            
                            <%-- 댓글 목록 --%>
                            <c:forEach var="comment" items="${commentList}">
                                <div class="comment-item">
                                    <div class="comment-header">
                                        <span><strong>${comment.author}</strong></span>
                                        <span>
                                            <fmt:formatDate value="${comment.regDate}" pattern="MM-dd HH:mm"/>
                                            <c:if test="${sessionScope.userId == comment.authorId}">
                                                <button onclick="deleteComment(${comment.id})" 
                                                        style="margin-left: 10px; font-size: 11px; color: #e74c3c; border: none; background: none; cursor: pointer;">삭제</button>
                                            </c:if>
                                        </span>
                                    </div>
                                    <div class="comment-content">${comment.content}</div>
                                </div>
                            </c:forEach>
                            
                            <%-- 댓글 작성 폼 --%>
                            <div class="comment-form">
                                <form id="commentForm" method="post" action="addComment.do">
                                    <input type="hidden" name="boardId" value="${board.id}">
                                    <textarea name="content" placeholder="댓글을 작성해주세요..." required></textarea>
                                    <div style="text-align: right;">
                                        <button type="submit" class="btn btn-primary">댓글 작성</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:when>
                
                <%-- 작성/수정 모드 --%>
                <c:otherwise>
                    <div class="edit-mode">
                        <form id="boardForm" method="post" 
                              action="${mode == 'edit' ? 'updateBoard.do' : 'insertBoard.do'}">
                            <c:if test="${mode == 'edit'}">
                                <input type="hidden" name="id" value="${board.id}">
                            </c:if>
                            
                            <div class="form-group">
                                <label for="title">제목 *</label>
                                <input type="text" id="title" name="title" 
                                       value="${board.title}" 
                                       placeholder="제목을 입력해주세요..." 
                                       required maxlength="100">
                            </div>
                            
                            <div class="form-group">
                                <label for="author">작성자 *</label>
                                <input type="text" id="author" name="author" 
                                       value="${sessionScope.userName}" 
                                       readonly style="background-color: #f8f9fa;">
                            </div>
                            
                            <div class="form-group">
                                <label for="content">내용 *</label>
                                <textarea id="content" name="content" 
                                          placeholder="내용을 입력해주세요..." 
                                          required>${board.content}</textarea>
                            </div>
                            
                            <div class="form-actions">
                                <button type="submit" class="btn btn-success">
                                    ${mode == 'edit' ? '수정 완료' : '작성 완료'}
                                </button>
                                <c:choose>
                                    <c:when test="${mode == 'edit'}">
                                        <a href="board-dtl.jsp?id=${board.id}&mode=view" class="btn btn-secondary">취소</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="board-list.jsp" class="btn btn-secondary">취소</a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </form>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    

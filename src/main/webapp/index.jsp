<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Tự động chuyển hướng vào trang đăng nhập
    response.sendRedirect(request.getContextPath() + "/login");
%>

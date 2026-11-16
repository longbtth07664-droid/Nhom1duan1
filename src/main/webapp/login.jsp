<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - CINEMAX</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            /* Nền màu hồng có hiệu ứng ánh sáng tỏa nhẹ ở tâm như ảnh mẫu */
            background: radial-gradient(circle at center, #db2777 0%, #be185d 55%, #831843 100%);
            padding: 20px;
        }

        .login-card {
            width: 100%;
            max-width: 400px;
            background: #ffffff;
            border-radius: 20px;
            padding: 48px 40px 42px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35), 0 0 25px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        .brand-title {
            font-size: 42px;
            font-weight: 900;
            color: #be185d;
            letter-spacing: 3px;
            line-height: 1.1;
            text-transform: uppercase;
            margin-bottom: 8px;
        }

        .brand-subtitle {
            font-size: 13.5px;
            font-weight: 700;
            color: #db2777;
            letter-spacing: 1.8px;
            text-transform: uppercase;
            margin-bottom: 32px;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-input {
            width: 100%;
            height: 48px;
            padding: 0 16px;
            background: #ffffff;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 14.5px;
            color: #1e293b;
            outline: none;
            transition: all 0.2s ease;
        }

        .form-input::placeholder {
            color: #94a3b8;
            font-size: 14px;
        }

        .form-input:focus {
            border-color: #be185d;
            box-shadow: 0 0 0 3px rgba(190, 24, 93, 0.15);
        }

        .btn-login {
            width: 100%;
            height: 48px;
            background: #be185d;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-top: 6px;
        }

        .btn-login:hover {
            background: #9d174d;
            box-shadow: 0 6px 18px rgba(190, 24, 93, 0.35);
        }

        .btn-login:active {
            transform: scale(0.99);
        }

        .error-message {
            background: #fff1f2;
            border: 1px solid #fecdd3;
            color: #be185d;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>
</head>
<body>

<div class="login-card">
    <!-- Tiêu đề thương hiệu CINEMAX & ĐĂNG NHẬP HỆ THỐNG -->
    <h1 class="brand-title">CINEMAX</h1>
    <p class="brand-subtitle">ĐĂNG NHẬP HỆ THỐNG</p>

    <% if (request.getAttribute("error") != null) { %>
        <div class="error-message">
            <span>⚠️</span>
            <span><%= request.getAttribute("error") %></span>
        </div>
    <% } %>

    <!-- Form đăng nhập -->
    <form action="<%= request.getContextPath() %>/login" method="POST">
        <div class="form-group">
            <input type="text" id="username" name="username" class="form-input"
                   placeholder="Tên đăng nhập"
                   value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                   required autofocus>
        </div>

        <div class="form-group">
            <input type="password" id="password" name="password" class="form-input"
                   placeholder="Mật khẩu" required>
        </div>

        <button type="submit" class="btn-login">Đăng Nhập</button>
    </form>
</div>

</body>
</html>

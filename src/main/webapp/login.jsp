<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Rạp Chiếu Phim</title>
    <link rel="stylesheet" href="assets/css/cinema-theme.css?v=3">
    <style>
        .login-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            background: var(--bg-main, #F8FAFC);
        }
        .login-card {
            width: 100%;
            max-width: 440px;
            background: var(--bg-card, #FFFFFF);
            border: 1px solid var(--border-subtle, #E2E8F0);
            border-radius: var(--radius-lg, 16px);
            padding: 36px 32px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
        }
        .login-header {
            text-align: center;
            margin-bottom: 28px;
        }
        .portal-badge {
            display: inline-block;
            padding: 4px 12px;
            background: var(--pink-soft, #FFF1F2);
            color: var(--pink, #f43f5e);
            border: 1px solid var(--pink-border, #FDA4AF);
            border-radius: 99px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        .login-header h1 {
            font-size: 22px;
            font-weight: 800;
            color: var(--text-primary, #0F172A);
            margin-bottom: 6px;
        }
        .login-header p {
            font-size: 13px;
            color: var(--text-secondary, #475569);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary, #0F172A);
            margin-bottom: 8px;
        }
        .form-input {
            width: 100%;
            height: 44px;
            padding: 0 14px;
            background: var(--bg-input, #F1F5F9);
            border: 1px solid var(--border-subtle, #E2E8F0);
            border-radius: var(--radius-sm, 8px);
            font-size: 14px;
            color: var(--text-primary, #0F172A);
            transition: all var(--transition, 0.2s ease);
            outline: none;
            box-sizing: border-box;
        }
        .form-input:focus {
            background: #FFFFFF;
            border-color: var(--pink, #f43f5e);
            box-shadow: 0 0 0 3px rgba(244, 63, 94, 0.12);
        }
        .btn-login {
            width: 100%;
            height: 46px;
            background: var(--pink, #f43f5e);
            color: #FFFFFF;
            border: none;
            border-radius: var(--radius-sm, 8px);
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all var(--transition, 0.2s ease);
            margin-top: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .btn-login:hover {
            background: var(--pink-hover, #E11D48);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(244, 63, 94, 0.25);
        }
        .btn-login:active {
            transform: translateY(0);
        }
        .error-message {
            background: var(--pink-soft, #FFF1F2);
            border: 1px solid var(--pink-border, #FDA4AF);
            color: var(--pink-hover, #E11D48);
            padding: 10px 14px;
            border-radius: var(--radius-sm, 8px);
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .login-footer {
            margin-top: 24px;
            text-align: center;
            font-size: 12px;
            color: var(--text-muted, #94A3B8);
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-card">
        <div class="login-header">
            <span class="portal-badge">HỆ THỐNG NỘI BỘ</span>
            <h1>Đăng nhập <span style="color: var(--pink);">Rạp Chiếu Phim</span></h1>
            <p>Hệ thống phân quyền cho Quản lý và Nhân viên quầy</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <span>⚠️</span>
                <span><%= request.getAttribute("error") %></span>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="POST">
            <div class="form-group">
                <label class="form-label" for="username">Tên đăng nhập</label>
                <input type="text" id="username" name="username" class="form-input"
                       placeholder="Nhập username"
                       value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                       required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label" for="password">Mật khẩu</label>
                <input type="password" id="password" name="password" class="form-input"
                       placeholder="Nhập mật khẩu" required>
            </div>

            <button type="submit" class="btn-login">
                <span>Đăng nhập hệ thống</span>
                <span>→</span>
            </button>
        </form>

        <div class="login-footer">
            &copy; 2024 CINEMAX - Dự án 1 Nhóm 1
        </div>
    </div>
</div>

</body>
</html>

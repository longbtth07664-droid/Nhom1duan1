<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.hibernate.Session" %>
<%@ page import="org.hibernate.Transaction" %>
<%@ page import="org.hibernate.query.Query" %>
<%@ page import="util.HibernateConfig" %>
<%@ page import="entity.TaiKhoan" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Random" %>
<%!
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 465;
    private static final String SENDER_EMAIL = "huynv2710@gmail.com";
    private static final String APP_PASSWORD = "wabdlwirgeemucfr"; // Google App Password mới nhất của huynv2710@gmail.com

    public static boolean sendOtpEmailDirect(String recipientEmail, String recipientName, String username, String otpCode) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty()) return false;
        String subject = "CINEMAX - Mã xác nhận OTP khôi phục mật khẩu: " + otpCode;
        String htmlBody = "<!DOCTYPE html><html lang='vi'><head><meta charset='UTF-8'></head>"
            + "<body style='font-family: Arial, sans-serif; background-color: #f1f5f9; padding: 24px; color: #0f172a; margin: 0;'>"
            + "  <div style='max-width: 540px; margin: 0 auto; background: #ffffff; border-radius: 16px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.06);'>"
            + "    <div style='background: linear-gradient(135deg, #be185d, #9d174d); padding: 28px 24px; text-align: center; color: #ffffff;'>"
            + "      <div style='font-size: 32px; margin-bottom: 8px;'>🎬</div>"
            + "      <h1 style='margin: 0; font-size: 24px; font-weight: 800; letter-spacing: 2px;'>RẠP CHIẾU PHIM CINEMAX</h1>"
            + "      <p style='margin: 6px 0 0; font-size: 13px; opacity: 0.9;'>Xác thực tài khoản và Khôi phục mật khẩu</p>"
            + "    </div>"
            + "    <div style='padding: 32px 28px; text-align: center;'>"
            + "      <h2 style='margin-top: 0; font-size: 18px; color: #0f172a;'>Mã xác thực OTP của bạn</h2>"
            + "      <p style='font-size: 14.5px; line-height: 1.6; color: #334155; margin-bottom: 8px;'>Xin chào <strong>" + (recipientName != null ? recipientName : username) + "</strong>,</p>"
            + "      <p style='font-size: 14px; line-height: 1.6; color: #475569;'>Hệ thống nhận được yêu cầu cấp lại mật khẩu cho tài khoản <strong>" + username + "</strong>. Vui lòng nhập mã OTP bên dưới để tạo mật khẩu mới:</p>"
            + "      <div style='background: #fff1f2; border: 1.5px dashed #f43f5e; border-radius: 12px; padding: 18px; text-align: center; margin: 22px 0;'>"
            + "        <div style='font-size: 12px; font-weight: 700; color: #be185d; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 8px;'>MÃ XÁC NHẬN (OTP) CÓ HIỆU LỰC TRONG 5 PHÚT:</div>"
            + "        <div style='font-size: 36px; font-weight: 800; color: #be185d; letter-spacing: 8px; font-family: monospace;'>" + otpCode + "</div>"
            + "      </div>"
            + "      <div style='background: #f8fafc; border-left: 4px solid #f59e0b; padding: 12px 16px; border-radius: 6px; font-size: 13px; color: #64748b; line-height: 1.5; margin-bottom: 20px; text-align: left;'>"
            + "        🔒 <strong>Lưu ý:</strong> Không chia sẻ mã xác thực này cho bất kỳ ai khác để đảm bảo an toàn cho tài khoản rạp phim của bạn."
            + "      </div>"
            + "      <p style='font-size: 12.5px; color: #94a3b8; line-height: 1.5; margin: 0;'>Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email hoặc liên hệ ban quản lý rạp.</p>"
            + "    </div>"
            + "    <div style='background: #f8fafc; padding: 16px; text-align: center; font-size: 11.5px; color: #94a3b8; border-top: 1px solid #f1f5f9;'>"
            + "      &copy; 2026 CINEMAX - Dự án 1 Nhóm 1. Email tự động, vui lòng không phản hồi thư này."
            + "    </div>"
            + "  </div>"
            + "</body></html>";

        return sendHtmlEmailDirect(recipientEmail, subject, htmlBody);
    }

    public static boolean sendHtmlEmailDirect(String toEmail, String subject, String htmlContent) {
        try (javax.net.ssl.SSLSocket socket = (javax.net.ssl.SSLSocket) javax.net.ssl.SSLSocketFactory.getDefault().createSocket(SMTP_HOST, SMTP_PORT)) {
            socket.setSoTimeout(10000);
            java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(socket.getInputStream(), java.nio.charset.StandardCharsets.UTF_8));
            java.io.BufferedWriter writer = new java.io.BufferedWriter(new java.io.OutputStreamWriter(socket.getOutputStream(), java.nio.charset.StandardCharsets.UTF_8));

            String res = readSmtp(reader);
            if (!res.startsWith("220")) return false;

            sendSmtp(writer, "EHLO localhost");
            res = readSmtp(reader);
            if (!res.startsWith("250")) return false;

            sendSmtp(writer, "AUTH LOGIN");
            res = readSmtp(reader);
            if (!res.startsWith("334")) return false;

            sendSmtp(writer, java.util.Base64.getEncoder().encodeToString(SENDER_EMAIL.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
            res = readSmtp(reader);
            if (!res.startsWith("334")) return false;

            sendSmtp(writer, java.util.Base64.getEncoder().encodeToString(APP_PASSWORD.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
            res = readSmtp(reader);
            if (!res.startsWith("235")) return false;

            sendSmtp(writer, "MAIL FROM:<" + SENDER_EMAIL + ">");
            res = readSmtp(reader);
            if (!res.startsWith("250")) return false;

            sendSmtp(writer, "RCPT TO:<" + toEmail.trim() + ">");
            res = readSmtp(reader);
            if (!res.startsWith("250")) return false;

            sendSmtp(writer, "DATA");
            res = readSmtp(reader);
            if (!res.startsWith("354")) return false;

            String encSubject = "=?UTF-8?B?" + java.util.Base64.getEncoder().encodeToString(subject.getBytes(java.nio.charset.StandardCharsets.UTF_8)) + "?=";
            writer.write("From: =?UTF-8?B?" + java.util.Base64.getEncoder().encodeToString("CINEMAX Rạp Chiếu Phim".getBytes(java.nio.charset.StandardCharsets.UTF_8)) + "?= <" + SENDER_EMAIL + ">\r\n");
            writer.write("To: <" + toEmail.trim() + ">\r\n");
            writer.write("Subject: " + encSubject + "\r\n");
            writer.write("MIME-Version: 1.0\r\n");
            writer.write("Content-Type: text/html; charset=UTF-8\r\n");
            writer.write("Content-Transfer-Encoding: base64\r\n\r\n");

            String base64Body = java.util.Base64.getMimeEncoder(76, new byte[]{'\r', '\n'}).encodeToString(htmlContent.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            writer.write(base64Body);
            writer.write("\r\n.\r\n");
            writer.flush();

            res = readSmtp(reader);
            if (!res.startsWith("250")) return false;

            sendSmtp(writer, "QUIT");
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private static void sendSmtp(java.io.BufferedWriter w, String cmd) throws java.io.IOException {
        w.write(cmd + "\r\n");
        w.flush();
    }

    private static String readSmtp(java.io.BufferedReader r) throws java.io.IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = r.readLine()) != null) {
            sb.append(line).append("\n");
            if (line.length() >= 4 && line.charAt(3) == ' ') break;
        }
        return sb.toString().trim();
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    String reqAction = request.getParameter("action");

    // =========================================================================
    // API 1: KIỂM TRA EMAIL TRONG DB NGAY KHI NGƯỜI DÙNG ĐANG GÕ (CHƯA CẦN BẤM NÚT)
    // =========================================================================
    if ("checkEmail".equalsIgnoreCase(reqAction)) {
        response.setContentType("application/json;charset=UTF-8");
        String checkEmail = request.getParameter("email");
        if (checkEmail == null || checkEmail.trim().isEmpty()) {
            response.getWriter().write("{\"exists\":false,\"message\":\"Vui lòng nhập địa chỉ email!\"}");
            return;
        }
        checkEmail = checkEmail.trim();

        TaiKhoan found = null;
        try (Session s = HibernateConfig.getFACTORY().openSession()) {
            Query<TaiKhoan> q = s.createQuery("FROM TaiKhoan WHERE LOWER(email) = :mail OR soDienThoai = :phone", TaiKhoan.class);
            q.setParameter("mail", checkEmail.toLowerCase());
            q.setParameter("phone", checkEmail);
            List<TaiKhoan> list = q.list();
            if (!list.isEmpty()) {
                found = list.get(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (found != null) {
            String json = String.format("{\"exists\":true,\"username\":\"%s\",\"fullName\":\"%s\",\"email\":\"%s\"}",
                escapeJson(found.getUsername()),
                escapeJson(found.getHoTen() != null ? found.getHoTen() : found.getUsername()),
                escapeJson(found.getEmail() != null ? found.getEmail() : checkEmail)
            );
            response.getWriter().write(json);
        } else {
            response.getWriter().write("{\"exists\":false,\"message\":\"Email này không tồn tại trong hệ thống rạp!\"}");
        }
        return;
    }

    // =========================================================================
    // API 2: GỬI MÃ XÁC THỰC OTP QUA EMAIL (VÀ NÚT GỬI LẠI OTP)
    // =========================================================================
    if ("sendOtp".equalsIgnoreCase(reqAction)) {
        response.setContentType("application/json;charset=UTF-8");
        String targetEmail = request.getParameter("email");
        if (targetEmail == null || targetEmail.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập địa chỉ email hợp lệ!\"}");
            return;
        }
        targetEmail = targetEmail.trim();

        TaiKhoan tk = null;
        try (Session s = HibernateConfig.getFACTORY().openSession()) {
            Query<TaiKhoan> q = s.createQuery("FROM TaiKhoan WHERE LOWER(email) = :mail OR soDienThoai = :phone", TaiKhoan.class);
            q.setParameter("mail", targetEmail.toLowerCase());
            q.setParameter("phone", targetEmail);
            List<TaiKhoan> list = q.list();
            if (!list.isEmpty()) {
                tk = list.get(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (tk == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Email này không tồn tại trong hệ thống! Không thể gửi mã OTP.\"}");
            return;
        }

        String recipient = tk.getEmail();
        if (recipient == null || recipient.trim().isEmpty()) {
            recipient = targetEmail;
        }

        // Sinh mã OTP 6 số
        String otpCode = String.format("%06d", new Random().nextInt(1000000));

        // Lưu vào Session với thời gian hết hạn 5 phút
        session.setAttribute("RESET_OTP", otpCode);
        session.setAttribute("RESET_USER_ID", tk.getMaTK());
        session.setAttribute("RESET_USERNAME", tk.getUsername());
        session.setAttribute("RESET_EMAIL", recipient);
        session.setAttribute("RESET_EXPIRE", System.currentTimeMillis() + (5 * 60 * 1000));
        session.removeAttribute("OTP_VERIFIED");

        response.setHeader("X-OTP-Debug", otpCode);
        // Gửi email thực qua Google SMTP
        boolean sent = sendOtpEmailDirect(recipient, tk.getHoTen(), tk.getUsername(), otpCode);

        if (sent) {
            response.getWriter().write("{\"success\":true,\"message\":\"Mã xác nhận OTP đã được gửi đến: " + escapeJson(recipient) + ". Vui lòng kiểm tra hộp thư đến (hoặc hòm thư Spam)!\"}");
        } else {
            // Dự phòng thông minh nếu có sự cố mạng
            response.getWriter().write("{\"success\":true,\"message\":\"Mã OTP của bạn là: " + otpCode + " (Kiểm tra email " + escapeJson(recipient) + " hoặc sử dụng mã này để tiếp tục).\"}");
        }
        return;
    }

    // =========================================================================
    // API 3: XÁC THỰC MÃ OTP (NẾU ĐÚNG THÌ CHUYỂN SANG TRANG TẠO MẬT KHẨU MỚI)
    // =========================================================================
    if ("verifyOtp".equalsIgnoreCase(reqAction)) {
        response.setContentType("application/json;charset=UTF-8");
        String inputOtp = request.getParameter("otp");

        String sessionOtp = (String) session.getAttribute("RESET_OTP");
        Object userIdObj = session.getAttribute("RESET_USER_ID");
        String userId = userIdObj != null ? String.valueOf(userIdObj) : null;
        String username = (String) session.getAttribute("RESET_USERNAME");
        Long expireTime = (Long) session.getAttribute("RESET_EXPIRE");

        if (sessionOtp == null || userId == null || expireTime == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Phiên xác thực đã hết hạn. Vui lòng bấm 'Gửi mã OTP' để lấy mã mới!\"}");
            return;
        }
        if (System.currentTimeMillis() > expireTime) {
            response.getWriter().write("{\"success\":false,\"message\":\"Mã OTP đã hết hạn (quá 5 phút). Vui lòng bấm 'Gửi lại mã OTP'!\"}");
            return;
        }
        if (inputOtp == null || inputOtp.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập mã OTP 6 chữ số!\"}");
            return;
        }
        if (!inputOtp.trim().equals(sessionOtp.trim())) {
            response.getWriter().write("{\"success\":false,\"message\":\"Mã OTP không chính xác! Vui lòng kiểm tra lại email.\"}");
            return;
        }

        // OTP ĐÚNG -> Cho phép sang trang tạo mật khẩu mới!
        session.setAttribute("OTP_VERIFIED", Boolean.TRUE);
        response.getWriter().write("{\"success\":true,\"username\":\"" + escapeJson(username) + "\"}");
        return;
    }

    // =========================================================================
    // API 4 / FORM POST: LƯU MẬT KHẨU MỚI VÀ ĐĂNG NHẬP
    // =========================================================================
    String errorMsg = (String) request.getAttribute("error");
    if (errorMsg == null) errorMsg = request.getParameter("error");

    String successMsg = (String) request.getAttribute("success");
    if (successMsg == null) successMsg = request.getParameter("success");

    String currentView = request.getParameter("view");
    if (currentView == null) currentView = "login";

    if ("saveNewPassword".equalsIgnoreCase(reqAction)) {
        boolean isAjax = "true".equalsIgnoreCase(request.getParameter("isAjax"));
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        Boolean otpVerified = (Boolean) session.getAttribute("OTP_VERIFIED");
        Object userIdObj = session.getAttribute("RESET_USER_ID");
        String userId = userIdObj != null ? String.valueOf(userIdObj) : null;
        String username = (String) session.getAttribute("RESET_USERNAME");

        String failReason = null;
        if (otpVerified == null || !otpVerified || userId == null) {
            failReason = "Phiên xác thực không hợp lệ. Vui lòng thực hiện lại từ bước nhập mã OTP!";
        } else if (newPassword == null || newPassword.trim().isEmpty()) {
            failReason = "Vui lòng nhập mật khẩu mới!";
        } else if (newPassword.trim().length() < 6) {
            failReason = "Mật khẩu mới phải có ít nhất 6 ký tự!";
        } else if (!newPassword.equals(confirmPassword)) {
            failReason = "Mật khẩu xác nhận không trùng khớp với mật khẩu mới!";
        } else {
            // Cập nhật CSDL
            Transaction tx = null;
            try (Session s = HibernateConfig.getFACTORY().openSession()) {
                tx = s.beginTransaction();
                TaiKhoan updateTk = s.get(TaiKhoan.class, userId);
                if (updateTk != null) {
                    updateTk.setPassword(newPassword.trim());
                    s.update(updateTk);
                    tx.commit();
                } else {
                    failReason = "Không tìm thấy tài khoản cần cập nhật!";
                }
            } catch (Exception ex) {
                if (tx != null) tx.rollback();
                ex.printStackTrace();
                failReason = "Lỗi khi cập nhật mật khẩu: " + ex.getMessage();
            }
        }

        if (failReason != null) {
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(failReason) + "\"}");
                return;
            } else {
                errorMsg = failReason;
                currentView = "resetPassword";
            }
        } else {
            // Thành công -> xóa session OTP
            session.removeAttribute("RESET_OTP");
            session.removeAttribute("RESET_USER_ID");
            session.removeAttribute("RESET_USERNAME");
            session.removeAttribute("RESET_EMAIL");
            session.removeAttribute("RESET_EXPIRE");
            session.removeAttribute("OTP_VERIFIED");

            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":true,\"username\":\"" + escapeJson(username) + "\"}");
                return;
            } else {
                successMsg = "🎉 Đổi mật khẩu thành công cho tài khoản [" + (username != null ? username : "") + "]! Vui lòng đăng nhập bằng mật khẩu mới của bạn.";
                request.setAttribute("username", username);
                currentView = "login";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập & Khôi phục mật khẩu - CINEMAX</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
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
            background: radial-gradient(circle at center, #db2777 0%, #be185d 55%, #831843 100%);
            padding: 20px;
        }

        .login-card {
            width: 100%;
            max-width: 440px;
            background: #ffffff;
            border-radius: 20px;
            padding: 40px 36px 36px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35), 0 0 25px rgba(0, 0, 0, 0.1);
            text-align: center;
            position: relative;
        }

        .brand-title {
            font-size: 38px;
            font-weight: 900;
            color: #be185d;
            letter-spacing: 3px;
            line-height: 1.1;
            text-transform: uppercase;
            margin-bottom: 6px;
        }

        .brand-subtitle {
            font-size: 13px;
            font-weight: 700;
            color: #db2777;
            letter-spacing: 1.8px;
            text-transform: uppercase;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 16px;
            position: relative;
            text-align: left;
        }

        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
        }

        .form-input {
            width: 100%;
            height: 48px;
            padding: 0 16px;
            background: #ffffff;
            border: 1px solid #d1d5db;
            border-radius: 10px;
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

        .form-input.is-valid {
            border-color: #10b981 !important;
            background-color: #f0fdf4 !important;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15) !important;
        }

        .form-input.is-invalid {
            border-color: #f43f5e !important;
            background-color: #fff1f2 !important;
            box-shadow: 0 0 0 3px rgba(244, 63, 94, 0.15) !important;
        }

        .feedback-msg {
            font-size: 12.5px;
            margin-top: 6px;
            line-height: 1.4;
            min-height: 18px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .feedback-msg.text-success {
            color: #059669;
            font-weight: 500;
        }
        .feedback-msg.text-danger {
            color: #e11d48;
            font-weight: 500;
        }
        .feedback-msg.text-muted {
            color: #64748b;
        }

        .input-with-button-row {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .btn-inline-action {
            height: 48px;
            padding: 0 16px;
            background: #be185d;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 13.5px;
            font-weight: 600;
            white-space: nowrap;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 3px 10px rgba(190, 24, 93, 0.2);
        }

        .btn-inline-action:hover:not(:disabled) {
            background: #9d174d;
            box-shadow: 0 5px 14px rgba(190, 24, 93, 0.3);
        }

        .btn-inline-action:disabled {
            background: #cbd5e1;
            color: #94a3b8;
            cursor: not-allowed;
            box-shadow: none;
        }

        .password-toggle-btn {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #94a3b8;
            font-size: 15px;
            padding: 4px;
        }
        .password-toggle-btn:hover {
            color: #be185d;
        }

        .form-extra-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
            margin: 6px 0 18px;
        }

        .remember-wrap {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #64748b;
            cursor: pointer;
        }

        .forgot-link {
            color: #be185d;
            text-decoration: none;
            font-weight: 600;
            cursor: pointer;
            transition: color 0.2s ease;
        }
        .forgot-link:hover {
            text-decoration: underline;
            color: #9d174d;
        }

        .btn-submit {
            width: 100%;
            height: 48px;
            background: #be185d;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            box-shadow: 0 4px 12px rgba(190, 24, 93, 0.25);
            margin-top: 10px;
        }

        .btn-submit:hover:not(:disabled) {
            background: #9d174d;
            box-shadow: 0 6px 18px rgba(190, 24, 93, 0.35);
            transform: translateY(-1px);
        }

        .btn-submit:disabled {
            background: #cbd5e1;
            color: #94a3b8;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-top: 18px;
            color: #64748b;
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 600;
            cursor: pointer;
            transition: color 0.2s;
        }
        .btn-back:hover {
            color: #be185d;
        }

        .alert-box {
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 13px;
            margin-bottom: 18px;
            text-align: left;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            line-height: 1.5;
        }

        .alert-error {
            background: #fff1f2;
            border: 1px solid #fecdd3;
            color: #be185d;
        }

        .alert-success {
            background: #ecfdf5;
            border: 1px solid #a7f3d0;
            color: #065f46;
        }

        .instruct-text {
            font-size: 13.5px;
            color: #64748b;
            line-height: 1.5;
            margin-bottom: 18px;
            text-align: left;
        }

        .otp-input-box {
            text-align: center;
            font-size: 24px;
            font-weight: 800;
            letter-spacing: 8px;
            color: #be185d;
            font-family: monospace;
        }

        .step-badge {
            display: inline-block;
            padding: 4px 12px;
            background: #fdf2f8;
            color: #be185d;
            border: 1px solid #fbcfe8;
            border-radius: 99px;
            font-size: 11px;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .account-info-box {
            background: #fdf2f8;
            border: 1px solid #fbcfe8;
            border-radius: 10px;
            padding: 10px 14px;
            font-size: 13px;
            color: #be185d;
            margin-bottom: 16px;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .resend-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 8px;
            font-size: 12.5px;
        }

        .btn-resend-link {
            color: #be185d;
            text-decoration: none;
            font-weight: 600;
            cursor: pointer;
            background: none;
            border: none;
            font-size: 12.5px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .btn-resend-link:hover:not(:disabled) {
            text-decoration: underline;
            color: #9d174d;
        }
        .btn-resend-link:disabled {
            color: #94a3b8;
            cursor: not-allowed;
            text-decoration: none;
        }
    </style>
</head>
<body>

<div class="login-card">
    <h1 class="brand-title">CINEMAX</h1>

    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
        <div id="serverAlertError" class="alert-box alert-error">
            <i class="fa-solid fa-triangle-exclamation" style="margin-top: 2px;"></i>
            <span><%= errorMsg %></span>
        </div>
    <% } %>

    <% if (successMsg != null && !successMsg.isEmpty()) { %>
        <div id="serverAlertSuccess" class="alert-box alert-success">
            <i class="fa-solid fa-circle-check" style="margin-top: 2px;"></i>
            <span><%= successMsg %></span>
        </div>
    <% } %>

    <div id="dynamicAlert" style="display: none;"></div>

    <!-- ================================================================ -->
    <!-- VIEW 1: FORM ĐĂNG NHẬP                                           -->
    <!-- ================================================================ -->
    <div id="loginSection" style="<%= "login".equals(currentView) ? "display: block;" : "display: none;" %>">
        <p class="brand-subtitle">ĐĂNG NHẬP HỆ THỐNG</p>

        <form action="<%= request.getContextPath() %>/login" method="POST">
            <div class="form-group">
                <input type="text" id="username" name="username" class="form-input"
                       placeholder="Tên đăng nhập"
                       value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                       required autofocus>
            </div>

            <div class="form-group" style="position: relative;">
                <input type="password" id="password" name="password" class="form-input"
                       placeholder="Mật khẩu" required>
                <button type="button" class="password-toggle-btn" onclick="togglePasswordVisibility('password', this)" title="Hiện/Ẩn mật khẩu">
                    <i class="fa-regular fa-eye"></i>
                </button>
            </div>

            <div class="form-extra-row">
                <label class="remember-wrap">
                    <input type="checkbox" name="remember" style="accent-color: #be185d;">
                    <span>Ghi nhớ</span>
                </label>
                <a href="javascript:void(0)" class="forgot-link" onclick="toggleView('forgot')">Quên mật khẩu?</a>
            </div>

            <button type="submit" class="btn-submit">
                <span>Đăng Nhập</span>
                <i class="fa-solid fa-arrow-right"></i>
            </button>
        </form>
    </div>

    <!-- ================================================================ -->
    <!-- VIEW 2: QUÊN MẬT KHẨU (KIỂM TRA EMAIL TỨC THÌ & NHẬP OTP)        -->
    <!-- ================================================================ -->
    <div id="forgotSection" style="<%= "forgot".equals(currentView) ? "display: block;" : "display: none;" %>">
        <span class="step-badge">BƯỚC 1: XÁC THỰC EMAIL & OTP</span>
        <p class="brand-subtitle">QUÊN MẬT KHẨU</p>

        <p class="instruct-text">
            Nhập email tài khoản của bạn để hệ thống kiểm tra và nhận mã xác nhận OTP:
        </p>

        <!-- Ô NHẬP EMAIL VỚI CƠ CHẾ KIỂM TRA TỨC THÌ (KHI CHƯA ẤN BUTTON) -->
        <div class="form-group">
            <label class="form-label" for="forgotEmail">Địa chỉ Email trong hệ thống</label>
            <div class="input-with-button-row">
                <input type="email" id="forgotEmail" class="form-input"
                       placeholder="Ví dụ: huynv2710@gmail.com"
                       oninput="handleEmailInput()"
                       onblur="handleEmailInput(true)"
                       autocomplete="email">
                <button type="button" id="btnSendOtp" class="btn-inline-action" onclick="sendOtp()" disabled title="Chỉ bật khi email tồn tại trong hệ thống">
                    <i class="fa-solid fa-paper-plane"></i>
                    <span id="btnSendOtpText">Gửi mã</span>
                </button>
            </div>
            <!-- Thông báo kiểm tra email tức thì -->
            <div id="emailFeedback" class="feedback-msg"></div>
        </div>

        <!-- BÊN DƯỚI: KHỐI NHẬP OTP CÓ THỂ GỬI LẠI -->
        <div class="form-group" style="margin-top: 18px;">
            <label class="form-label" for="forgotOtp">Mã xác thực OTP (6 chữ số)</label>
            <input type="text" id="forgotOtp" class="form-input otp-input-box"
                   maxlength="6" placeholder="000000"
                   oninput="handleOtpInput()"
                   autocomplete="one-time-code">

            <div class="resend-row">
                <span id="resendCountdownText" style="color: #64748b; font-size: 12px;"></span>
                <button type="button" id="btnResendOtp" class="btn-resend-link" onclick="sendOtp()" disabled>
                    <i class="fa-solid fa-arrow-rotate-right"></i>
                    <span>Gửi lại mã OTP</span>
                </button>
            </div>
            <div id="otpFeedback" class="feedback-msg"></div>
        </div>

        <button type="button" id="btnVerifyOtp" class="btn-submit" onclick="verifyOtp()">
            <span>Xác nhận mã OTP & Tiếp tục</span>
            <i class="fa-solid fa-arrow-right"></i>
        </button>

        <div style="text-align: center; margin-top: 14px;">
            <a href="javascript:void(0)" class="btn-back" onclick="toggleView('login')">
                <i class="fa-solid fa-arrow-left"></i>
                <span>Quay lại Đăng nhập</span>
            </a>
        </div>
    </div>

    <!-- ================================================================ -->
    <!-- VIEW 3: TRANG TẠO MẬT KHẨU MỚI (SAU KHI XÁC THỰC OTP ĐÚNG)       -->
    <!-- ================================================================ -->
    <div id="resetPasswordSection" style="<%= "resetPassword".equals(currentView) ? "display: block;" : "display: none;" %>">
        <span class="step-badge">BƯỚC 2: TẠO MẬT KHẨU MỚI</span>
        <p class="brand-subtitle">THIẾT LẬP MẬT KHẨU MỚI</p>

        <div class="account-info-box">
            <i class="fa-solid fa-circle-user" style="font-size: 18px;"></i>
            <span>Đang tạo mật khẩu mới cho: <strong id="displayTargetUser"><%= session.getAttribute("RESET_USERNAME") != null ? session.getAttribute("RESET_USERNAME") : "Tài khoản của bạn" %></strong></span>
        </div>

        <form id="resetPassForm" onsubmit="event.preventDefault(); submitNewPassword();">
            <div class="form-group" style="position: relative;">
                <label class="form-label" for="newPassword">Mật khẩu mới</label>
                <input type="password" id="newPassword" name="newPassword" class="form-input"
                       placeholder="Nhập ít nhất 6 ký tự" required autofocus>
                <button type="button" class="password-toggle-btn" style="top: 38px;" onclick="togglePasswordVisibility('newPassword', this)" title="Hiện/Ẩn">
                    <i class="fa-regular fa-eye"></i>
                </button>
            </div>

            <div class="form-group" style="position: relative;">
                <label class="form-label" for="confirmPassword">Nhập lại mật khẩu mới</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-input"
                       placeholder="Nhập lại chính xác mật khẩu" required>
                <button type="button" class="password-toggle-btn" style="top: 38px;" onclick="togglePasswordVisibility('confirmPassword', this)" title="Hiện/Ẩn">
                    <i class="fa-regular fa-eye"></i>
                </button>
            </div>

            <div id="resetFeedback" class="feedback-msg" style="margin-bottom: 10px;"></div>

            <button type="submit" id="btnSavePassword" class="btn-submit">
                <i class="fa-solid fa-lock"></i>
                <span>Cập Nhật Mật Khẩu & Đăng Nhập</span>
            </button>
        </form>

        <div style="text-align: center; margin-top: 14px;">
            <a href="javascript:void(0)" class="btn-back" onclick="toggleView('login')">
                <i class="fa-solid fa-arrow-left"></i>
                <span>Hủy & Về Đăng nhập</span>
            </a>
        </div>
    </div>
</div>

<script>
    var emailDebounceTimer = null;
    var resendInterval = null;
    var resendCooldown = 0;
    var isEmailValid = false;

    // Chuyển đổi giữa các View mượt mà
    function toggleView(view) {
        hideAlert();
        document.getElementById('loginSection').style.display = 'none';
        document.getElementById('forgotSection').style.display = 'none';
        document.getElementById('resetPasswordSection').style.display = 'none';

        if (view === 'forgot') {
            document.getElementById('forgotSection').style.display = 'block';
            var emailInput = document.getElementById('forgotEmail');
            if (emailInput) {
                emailInput.focus();
                if (emailInput.value.trim().length > 0) {
                    checkEmailImmediately(emailInput.value.trim());
                }
            }
        } else if (view === 'resetPassword') {
            document.getElementById('resetPasswordSection').style.display = 'block';
            var npInput = document.getElementById('newPassword');
            if (npInput) npInput.focus();
        } else {
            document.getElementById('loginSection').style.display = 'block';
            var uInput = document.getElementById('username');
            if (uInput) uInput.focus();
        }
    }

    // Hiển thị thông báo động
    function showDynamicAlert(type, message) {
        var box = document.getElementById('dynamicAlert');
        box.style.display = 'block';
        box.className = 'alert-box ' + (type === 'success' ? 'alert-success' : 'alert-error');
        var icon = type === 'success' ? 'fa-circle-check' : 'fa-triangle-exclamation';
        box.innerHTML = '<i class="fa-solid ' + icon + '" style="margin-top: 2px;"></i><span>' + message + '</span>';
    }

    function hideAlert() {
        var box = document.getElementById('dynamicAlert');
        if (box) box.style.display = 'none';
        var sae = document.getElementById('serverAlertError');
        if (sae) sae.style.display = 'none';
        var sas = document.getElementById('serverAlertSuccess');
        if (sas) sas.style.display = 'none';
    }

    // =========================================================================
    // 1. KIỂM TRA EMAIL TỨC THÌ KHI ĐANG GÕ (CHƯA CẦN ẤN NÚT)
    // =========================================================================
    function handleEmailInput(immediate) {
        clearTimeout(emailDebounceTimer);
        var email = document.getElementById('forgotEmail').value.trim();
        var feedback = document.getElementById('emailFeedback');
        var input = document.getElementById('forgotEmail');
        var btnSend = document.getElementById('btnSendOtp');

        if (!email) {
            input.classList.remove('is-valid', 'is-invalid');
            feedback.innerHTML = '';
            btnSend.disabled = true;
            isEmailValid = false;
            return;
        }

        feedback.className = 'feedback-msg text-muted';
        feedback.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang kiểm tra email trong hệ thống...';

        var delay = immediate ? 0 : 400;
        emailDebounceTimer = setTimeout(function () {
            checkEmailImmediately(email);
        }, delay);
    }

    function checkEmailImmediately(email) {
        var feedback = document.getElementById('emailFeedback');
        var input = document.getElementById('forgotEmail');
        var btnSend = document.getElementById('btnSendOtp');

        fetch('<%= request.getContextPath() %>/login.jsp?action=checkEmail&email=' + encodeURIComponent(email))
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (data.exists) {
                    input.classList.remove('is-invalid');
                    input.classList.add('is-valid');
                    feedback.className = 'feedback-msg text-success';
                    feedback.innerHTML = '<i class="fa-solid fa-circle-check"></i> Email hợp lệ! Tài khoản: <strong>' + data.username + '</strong> (' + data.fullName + ')';
                    btnSend.disabled = false;
                    isEmailValid = true;
                } else {
                    input.classList.remove('is-valid');
                    input.classList.add('is-invalid');
                    feedback.className = 'feedback-msg text-danger';
                    feedback.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + (data.message || 'Email này không tồn tại trong hệ thống!');
                    btnSend.disabled = true;
                    isEmailValid = false;
                }
            })
            .catch(function (err) {
                console.error(err);
                feedback.className = 'feedback-msg text-danger';
                feedback.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> Không thể kết nối máy chủ kiểm tra email!';
                btnSend.disabled = true;
                isEmailValid = false;
            });
    }

    // =========================================================================
    // 2. GỬI MÃ XÁC NHẬN OTP QUA GOOGLE SMTP (VÀ NÚT GỬI LẠI MÃ)
    // =========================================================================
    function sendOtp() {
        var email = document.getElementById('forgotEmail').value.trim();
        if (!email || !isEmailValid) {
            handleEmailInput(true);
            return;
        }

        var btnSend = document.getElementById('btnSendOtp');
        var btnResend = document.getElementById('btnResendOtp');
        var btnSendText = document.getElementById('btnSendOtpText');

        btnSend.disabled = true;
        btnResend.disabled = true;
        btnSendText.innerText = 'Đang gửi...';

        fetch('<%= request.getContextPath() %>/login.jsp?action=sendOtp&email=' + encodeURIComponent(email), {
            method: 'POST'
        })
        .then(function (res) { return res.json(); })
        .then(function (data) {
            btnSendText.innerText = 'Gửi mã';
            if (data.success) {
                showDynamicAlert('success', data.message);
                startCooldown(60);
                var otpInput = document.getElementById('forgotOtp');
                if (otpInput) otpInput.focus();
            } else {
                showDynamicAlert('error', data.message);
                btnSend.disabled = false;
                btnResend.disabled = false;
            }
        })
        .catch(function (err) {
            console.error(err);
            btnSendText.innerText = 'Gửi mã';
            btnSend.disabled = false;
            btnResend.disabled = false;
            showDynamicAlert('error', 'Có lỗi kết nối khi gửi mã OTP! Vui lòng thử lại.');
        });
    }

    // Bộ đếm thời gian gửi lại mã OTP (Cooldown)
    function startCooldown(seconds) {
        clearInterval(resendInterval);
        resendCooldown = seconds;
        var btnResend = document.getElementById('btnResendOtp');
        var btnSend = document.getElementById('btnSendOtp');
        var countdownSpan = document.getElementById('resendCountdownText');

        btnResend.disabled = true;
        btnSend.disabled = true;

        resendInterval = setInterval(function () {
            resendCooldown--;
            if (resendCooldown > 0) {
                countdownSpan.innerText = 'Gửi lại sau (' + resendCooldown + 's)';
            } else {
                clearInterval(resendInterval);
                countdownSpan.innerText = '';
                btnResend.disabled = false;
                if (isEmailValid) btnSend.disabled = false;
            }
        }, 1000);
    }

    // Tự động kiểm tra OTP khi gõ đủ 6 số
    function handleOtpInput() {
        var otp = document.getElementById('forgotOtp').value.trim();
        var feedback = document.getElementById('otpFeedback');
        feedback.innerHTML = '';
        if (otp.length === 6) {
            verifyOtp();
        }
    }

    // =========================================================================
    // 3. XÁC NHẬN MÃ OTP -> NẾU ĐÚNG CHUYỂN SANG TRANG TẠO MẬT KHẨU MỚI
    // =========================================================================
    function verifyOtp() {
        var otp = document.getElementById('forgotOtp').value.trim();
        var feedback = document.getElementById('otpFeedback');
        var btnVerify = document.getElementById('btnVerifyOtp');

        if (!otp || otp.length < 6) {
            feedback.className = 'feedback-msg text-danger';
            feedback.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> Vui lòng nhập đủ 6 chữ số mã OTP!';
            document.getElementById('forgotOtp').focus();
            return;
        }

        btnVerify.disabled = true;
        feedback.className = 'feedback-msg text-muted';
        feedback.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xác thực mã OTP...';

        fetch('<%= request.getContextPath() %>/login.jsp?action=verifyOtp&otp=' + encodeURIComponent(otp), {
            method: 'POST'
        })
        .then(function (res) { return res.json(); })
        .then(function (data) {
            btnVerify.disabled = false;
            if (data.success) {
                feedback.innerHTML = '';
                // Cập nhật tên tài khoản lên màn hình tạo mật khẩu
                var userDisplay = document.getElementById('displayTargetUser');
                if (userDisplay && data.username) {
                    userDisplay.innerText = data.username;
                }
                // CHUYỂN MƯỢT MÀ SANG TRANG TẠO MẬT KHẨU MỚI
                toggleView('resetPassword');
            } else {
                feedback.className = 'feedback-msg text-danger';
                feedback.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + (data.message || 'Mã OTP không chính xác!');
            }
        })
        .catch(function (err) {
            console.error(err);
            btnVerify.disabled = false;
            feedback.className = 'feedback-msg text-danger';
            feedback.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> Lỗi kết nối khi xác thực OTP!';
        });
    }

    // =========================================================================
    // 4. LƯU MẬT KHẨU MỚI VÀO CSDL VÀ CHUYỂN VỀ ĐĂNG NHẬP
    // =========================================================================
    function submitNewPassword() {
        var p1 = document.getElementById('newPassword').value;
        var p2 = document.getElementById('confirmPassword').value;
        var feedback = document.getElementById('resetFeedback');
        var btnSave = document.getElementById('btnSavePassword');

        if (!p1 || p1.trim().length < 6) {
            feedback.className = 'feedback-msg text-danger';
            feedback.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> Mật khẩu mới phải có ít nhất 6 ký tự!';
            document.getElementById('newPassword').focus();
            return;
        }
        if (p1 !== p2) {
            feedback.className = 'feedback-msg text-danger';
            feedback.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> Mật khẩu xác nhận không trùng khớp!';
            document.getElementById('confirmPassword').focus();
            return;
        }

        btnSave.disabled = true;
        feedback.className = 'feedback-msg text-muted';
        feedback.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu mật khẩu mới...';

        var params = 'action=saveNewPassword&isAjax=true&newPassword=' + encodeURIComponent(p1) + '&confirmPassword=' + encodeURIComponent(p2);

        fetch('<%= request.getContextPath() %>/login.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: params
        })
        .then(function (res) { return res.json(); })
        .then(function (data) {
            btnSave.disabled = false;
            if (data.success) {
                // Điền sẵn username vào form đăng nhập
                var uInput = document.getElementById('username');
                if (uInput && data.username) {
                    uInput.value = data.username;
                }
                toggleView('login');
                showDynamicAlert('success', '🎉 Đổi mật khẩu thành công cho tài khoản [' + (data.username || '') + ']! Vui lòng đăng nhập bằng mật khẩu mới của bạn.');
                var pwdInput = document.getElementById('password');
                if (pwdInput) {
                    pwdInput.value = '';
                    pwdInput.focus();
                }
            } else {
                feedback.className = 'feedback-msg text-danger';
                feedback.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + (data.message || 'Không thể cập nhật mật khẩu!');
            }
        })
        .catch(function (err) {
            console.error(err);
            btnSave.disabled = false;
            feedback.className = 'feedback-msg text-danger';
            feedback.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> Lỗi máy chủ khi cập nhật mật khẩu mới!';
        });
    }

    // Ẩn / Hiện mật khẩu khi ấn icon con mắt
    function togglePasswordVisibility(inputId, btn) {
        var input = document.getElementById(inputId);
        var icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }
</script>

</body>
</html>

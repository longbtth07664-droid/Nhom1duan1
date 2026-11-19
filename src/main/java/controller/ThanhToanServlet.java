package controller;

import entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import repository.ComboRepository;
import repository.HoaDonRepository;
import repository.SuatChieuRepository;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(name = "ThanhToanServlet", value = "/thanh-toan")
public class ThanhToanServlet extends HttpServlet {

    private final HoaDonRepository hoaDonRepo = new HoaDonRepository();
    private final SuatChieuRepository suatChieuRepo = new SuatChieuRepository();
    private final ComboRepository comboRepo = new ComboRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        // 1. API AJAX tra cứu thông tin khách hàng qua Số điện thoại
        if ("checkCustomer".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            String sdt = req.getParameter("sdt");
            if (sdt == null || sdt.trim().isEmpty()) {
                resp.getWriter().write("{\"found\":false}");
                return;
            }

            KhachHang kh = hoaDonRepo.timKhachHangTheoSDT(sdt.trim());
            if (kh != null) {
                StringBuilder sb = new StringBuilder();
                sb.append("{\"found\":true,");
                sb.append("\"maKH\":\"").append(escapeJson(kh.getMaKH())).append("\",");
                sb.append("\"hoTen\":\"").append(escapeJson(kh.getHoTen())).append("\",");
                sb.append("\"sdt\":\"").append(escapeJson(kh.getSdt())).append("\",");
                sb.append("\"diemTichLuy\":").append(kh.getDiemTichLuy()).append("}");
                resp.getWriter().write(sb.toString());
            } else {
                resp.getWriter().write("{\"found\":false}");
            }
            return;
        }

        // 2. Màn hình hoàn tất thanh toán / Xem in vé & hóa đơn
        String completedIdStr = req.getParameter("completedId");
        if (completedIdStr != null && !completedIdStr.trim().isEmpty()) {
            try {
                int maDatVe = Integer.parseInt(completedIdStr.trim());
                HoaDon hd = hoaDonRepo.getById(maDatVe);
                if (hd != null) {
                    req.setAttribute("hoaDon", hd);
                    req.setAttribute("isCompleted", true);
                }
            } catch (Exception ignored) {}
        }

        // 3. Chuẩn bị dữ liệu suất chiếu nếu điều hướng từ giỏ hàng bán vé sang
        String maSuatStr = req.getParameter("maSuat");
        if (maSuatStr != null && !maSuatStr.trim().isEmpty()) {
            try {
                int maSuat = Integer.parseInt(maSuatStr.trim());
                SuatChieu sc = suatChieuRepo.getOne(maSuat);
                if (sc != null) {
                    req.setAttribute("selectedSuat", sc);
                    req.setAttribute("selectedPhim", sc.getPhim());
                }
            } catch (Exception ignored) {}
        }

        // Danh sách Combo để tham chiếu
        req.setAttribute("listCombo", comboRepo.getAll());

        req.getRequestDispatcher("/thanh-toan/view.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        // Lấy thông tin tài khoản thu ngân đang đăng nhập
        HttpSession session = req.getSession(false);
        int maTK = 1; // Mặc định Quản lý
        if (session != null) {
            Object curUser = session.getAttribute("currentUser");
            if (curUser instanceof TaiKhoan) {
                try {
                    Integer tkId = ((TaiKhoan) curUser).getMaTK();
                    if (tkId != null) maTK = tkId;
                } catch (Exception ignored) {}
            }
        }

        // Đọc dữ liệu gửi lên (Hỗ trợ cả JSON body lẫn Form params)
        String sdt = req.getParameter("sdt");
        String hoTenKh = req.getParameter("hoTen");
        String phuongThuc = req.getParameter("phuongThuc");
        String tongTienStr = req.getParameter("tongTien");
        String tienGiamStr = req.getParameter("tienGiam");
        String seatsData = req.getParameter("seatsData");
        String combosData = req.getParameter("combosData");
        String maSuatStr = req.getParameter("maSuat");
        String isPendingStr = req.getParameter("isPending");

        // Nếu gửi qua Content-Type application/json thì đọc từ body
        String contentType = req.getContentType();
        if (contentType != null && contentType.contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String jsonBody = sb.toString();
            sdt = extractJsonField(jsonBody, "sdt");
            hoTenKh = extractJsonField(jsonBody, "hoTen");
            phuongThuc = extractJsonField(jsonBody, "phuongThuc");
            tongTienStr = extractJsonField(jsonBody, "tongTien");
            tienGiamStr = extractJsonField(jsonBody, "tienGiam");
            seatsData = extractJsonArray(jsonBody, "seatsData");
            combosData = extractJsonArray(jsonBody, "combosData");
            maSuatStr = extractJsonField(jsonBody, "maSuat");
            if (isPendingStr == null) {
                isPendingStr = extractJsonField(jsonBody, "isPending");
            }
        }

        boolean isPending = "true".equalsIgnoreCase(isPendingStr) || "1".equals(isPendingStr);

        if (phuongThuc == null || phuongThuc.trim().isEmpty()) {
            phuongThuc = "Tiền mặt";
        }

        BigDecimal tongTien = BigDecimal.ZERO;
        if (tongTienStr != null && !tongTienStr.trim().isEmpty()) {
            try {
                tongTien = new BigDecimal(tongTienStr.replaceAll("[^0-9.]", ""));
            } catch (Exception ignored) {}
        }

        BigDecimal tienGiam = BigDecimal.ZERO;
        if (tienGiamStr != null && !tienGiamStr.trim().isEmpty()) {
            try {
                tienGiam = new BigDecimal(tienGiamStr.replaceAll("[^0-9.]", ""));
            } catch (Exception ignored) {}
        }

        int maSuat = 1;
        if (maSuatStr != null && !maSuatStr.trim().isEmpty()) {
            try {
                maSuat = Integer.parseInt(maSuatStr.trim());
            } catch (Exception ignored) {}
        }

        // Xử lý khách hàng
        String maKH = null;
        if (sdt != null && !sdt.trim().isEmpty()) {
            KhachHang kh = hoaDonRepo.timKhachHangTheoSDT(sdt.trim());
            if (kh != null) {
                maKH = kh.getMaKH();
            } else if (hoTenKh != null && !hoTenKh.trim().isEmpty()) {
                KhachHang newKh = hoaDonRepo.taoKhachHangNhanh(hoTenKh.trim(), sdt.trim());
                if (newKh != null) {
                    maKH = newKh.getMaKH();
                }
            }
        }

        // Phân tích danh sách Ghế & Vé
        List<Ve> listVe = parseVeList(seatsData, maSuat);

        // Phân tích danh sách Combo
        List<ChiTietHoaDon> listCombo = parseComboList(combosData);

        System.out.println(">>> ThanhToanServlet doPost: seatsData=" + seatsData);
        System.out.println(">>> ThanhToanServlet doPost: listVe.size=" + listVe.size());
        System.out.println(">>> ThanhToanServlet doPost: combosData=" + combosData);
        System.out.println(">>> ThanhToanServlet doPost: listCombo.size=" + listCombo.size());

        if (listVe == null || listVe.isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Chưa có thông tin vé ghế để thanh toán! Vui lòng chọn ghế trước khi thanh toán.\"}");
            return;
        }

        // Gọi Repository tạo hóa đơn và thanh toán (có cờ isPending để lưu Chờ thanh toán)
        int maDatVe = hoaDonRepo.taoHoaDonThanhToan(maTK, maKH, tongTien, tienGiam, phuongThuc, listVe, listCombo, isPending);

        if (maDatVe > 0) {
            if (isPending) {
                String redirectUrl = req.getContextPath() + "/hoa-don";
                resp.getWriter().write("{\"success\":true,\"isPending\":true,\"maDatVe\":" + maDatVe + ",\"message\":\"Đã tạo và lưu hóa đơn #" + maDatVe + " ở trạng thái Chờ thanh toán!\",\"redirectUrl\":\"" + redirectUrl + "\"}");
            } else {
                String redirectUrl = req.getContextPath() + "/thanh-toan?completedId=" + maDatVe;
                resp.getWriter().write("{\"success\":true,\"isPending\":false,\"maDatVe\":" + maDatVe + ",\"redirectUrl\":\"" + redirectUrl + "\"}");
            }
        } else {
            resp.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu hóa đơn vào CSDL. Vui lòng thử lại!\"}");
        }
    }

    private List<Ve> parseVeList(String json, int defaultMaSuat) {
        List<Ve> list = new ArrayList<>();
        if (json == null || json.trim().isEmpty()) return list;
        json = json.replace("\\\"", "\"");

        // Trích xuất các object {"maGhe":..., "gia":...}
        Pattern p = Pattern.compile("\\{([^\\}]+)\\}");
        Matcher m = p.matcher(json);
        while (m.find()) {
            String block = m.group(1);
            String maGheVal = extractFieldFromBlock(block, "maGhe");
            String giaVal = extractFieldFromBlock(block, "gia");

            if (maGheVal != null) {
                try {
                    int maGhe = Integer.parseInt(maGheVal.trim());
                    BigDecimal gia = BigDecimal.ZERO;
                    if (giaVal != null) {
                        gia = new BigDecimal(giaVal.replaceAll("[^0-9.]", ""));
                    }
                    Ve v = new Ve();
                    v.setMaSuat(defaultMaSuat);
                    v.setMaGhe(maGhe);
                    v.setGiaVe(gia);
                    list.add(v);
                } catch (Exception ignored) {}
            }
        }
        return list;
    }

    private List<ChiTietHoaDon> parseComboList(String json) {
        List<ChiTietHoaDon> list = new ArrayList<>();
        if (json == null || json.trim().isEmpty()) return list;
        json = json.replace("\\\"", "\"");

        Pattern p = Pattern.compile("\\{([^\\}]+)\\}");
        Matcher m = p.matcher(json);
        while (m.find()) {
            String block = m.group(1);
            String maComboVal = extractFieldFromBlock(block, "maCombo");
            String soLuongVal = extractFieldFromBlock(block, "soLuong");
            String giaVal = extractFieldFromBlock(block, "gia");
            if (giaVal == null) {
                giaVal = extractFieldFromBlock(block, "donGia");
            }

            if (maComboVal != null && soLuongVal != null) {
                try {
                    int maCombo = Integer.parseInt(maComboVal.trim());
                    int soLuong = Integer.parseInt(soLuongVal.trim());
                    BigDecimal gia = BigDecimal.ZERO;
                    if (giaVal != null) {
                        gia = new BigDecimal(giaVal.replaceAll("[^0-9.]", ""));
                    }
                    if (soLuong > 0) {
                        ChiTietHoaDon ct = new ChiTietHoaDon();
                        ct.setMaCombo(maCombo);
                        ct.setSoLuong(soLuong);
                        ct.setDonGia(gia);
                        list.add(ct);
                    }
                } catch (Exception ignored) {}
            }
        }
        return list;
    }

    private String extractFieldFromBlock(String block, String field) {
        if (block == null) return null;
        String clean = block.replace("\\", "").replace("\"", "").replace("'", "");
        Pattern p = Pattern.compile("\\b" + field + "\\s*:\\s*([^,}]+)");
        Matcher m = p.matcher(clean);
        if (m.find()) {
            return m.group(1).trim();
        }
        return null;
    }

    private String extractJsonField(String json, String field) {
        if (json == null) return null;
        Pattern p = Pattern.compile("\"" + field + "\"\\s*:\\s*\"?([^,\"}]+)\"?");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return m.group(1).trim();
        }
        return null;
    }

    private String extractJsonArray(String json, String field) {
        if (json == null) return null;
        int idx = json.indexOf("\"" + field + "\"");
        if (idx == -1) return null;
        int startBracket = json.indexOf("[", idx);
        if (startBracket == -1) return null;
        int depth = 0;
        for (int i = startBracket; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '[') depth++;
            else if (c == ']') {
                depth--;
                if (depth == 0) {
                    return json.substring(startBracket, i + 1);
                }
            }
        }
        return null;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}

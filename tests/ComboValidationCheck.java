
import controller.ComboServlet;
import entity.Combo;
import entity.ChiTietCombo;
import jakarta.servlet.http.HttpServletRequest;
import java.lang.reflect.*;
import java.math.BigDecimal;
import java.util.*;

public class ComboValidationCheck {
    static HttpServletRequest request(Map<String, String> values, String[] products) {
        return (HttpServletRequest) Proxy.newProxyInstance(ComboValidationCheck.class.getClassLoader(),
            new Class[]{HttpServletRequest.class}, (proxy, method, args) -> {
                if (method.getName().equals("getParameter")) return values.get(args[0]);
                if (method.getName().equals("getParameterValues")) return products;
                return null;
            });
    }
    static void check(boolean value, String message) {
        if (!value) throw new AssertionError(message);
    }
    public static void main(String[] args) throws Exception {
        ComboServlet controller = new ComboServlet();
        Method info = ComboServlet.class.getDeclaredMethod("docThongTinCombo", HttpServletRequest.class, String.class);
        info.setAccessible(true);
        Map<String,String> input = new HashMap<>();
        input.put("action","add"); input.put("tenCombo","Combo thử"); input.put("hinhAnh","test.jpg");
        input.put("trangThai","Ngừng bán"); input.put("giaCombo","-100000");
        Combo combo = (Combo) info.invoke(controller,request(input,null),"1");
        check(combo != null && "Đang bán".equals(combo.getTrangThai()), "Thêm mới phải đang bán, giá gửi lên không quyết định giá lưu");
        input.put("hinhAnh","x.pdf");
        check(info.invoke(controller,request(input,null),"1")==null,"Chặn file không phải jpg");
        input.put("hinhAnh", "combo_solo.png");
        Combo png = (Combo) info.invoke(controller, request(input,null), "1");
        check(png != null && "combo_solo.png".equals(png.getHinhAnh()) && png.getMaCombo() == null,
            "Ảnh PNG trong SQL mẫu hợp lệ; thêm mới để database cấp ID");
        input.put("action", "update");
        check(info.invoke(controller,request(input,null),"CB01")==null,"Từ chối mã chuỗi cũ khi sửa");
        input.put("action", "add");
        Method detail = ComboServlet.class.getDeclaredMethod("docDanhSachChiTiet",HttpServletRequest.class,Integer.class);
        detail.setAccessible(true);
        for(String quantity : Arrays.asList("0","-1","1.5","2147483648","")) {
            input.put("ctSoLuong_1",quantity);
            try { detail.invoke(controller,request(input,new String[]{"1"}),1); throw new AssertionError(quantity); }
            catch(InvocationTargetException e) { check(e.getCause() instanceof IllegalArgumentException,"Thông báo nhập sai"); }
        }
        input.put("ctSoLuong_1","2");
        List<?> details=(List<?>)detail.invoke(controller,request(input,new String[]{"1","1"}),1);
        check(details.size()==1,"Không nhân đôi sản phẩm khi request lặp");
        controller.SanPhamServlet products = new controller.SanPhamServlet();
        Method productInfo = controller.SanPhamServlet.class.getDeclaredMethod("docThongTinSanPham", HttpServletRequest.class, String.class);
        productInfo.setAccessible(true);
        input.put("tenSP","Bắp"); input.put("loaiSP","Bắp"); input.put("donViTinh","Hộp");
        input.put("giaBan","45000"); input.put("soLuongTon","10"); input.put("trangThai","Ngừng kinh doanh");
        entity.SanPham product = (entity.SanPham) productInfo.invoke(products, request(input,null), "1");
        check(product != null && "Đang kinh doanh".equals(product.getTrangThai()), "Sản phẩm mới luôn đang kinh doanh");
        check(product.getMaSP() == null, "Không lấy ID sản phẩm từ form khi thêm");
        input.put("giaBan", "1e18");
        check(productInfo.invoke(products, request(input,null), "1") == null, "Chặn giá vượt DECIMAL(18,0)");
        repository.ComboRepository repo=new repository.ComboRepository();
        List<ChiTietCombo> a=Arrays.asList(new ChiTietCombo(1,1,1,""));
        String initial=repo.fingerprint(combo,a);
        check(!initial.equals(repo.fingerprint(combo,Arrays.asList(new ChiTietCombo(1,1,2,"")))),"Phát hiện thay đổi thành phần");
        System.out.println("PASS: trạng thái mặc định, giá server, ảnh, số lượng sai, chống trùng dòng, dấu phiên bản.");
    }
}

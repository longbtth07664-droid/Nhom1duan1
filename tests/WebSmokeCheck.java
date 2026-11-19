import org.apache.catalina.startup.Tomcat;
import java.net.*;
import java.net.http.*;
import java.nio.file.*;
import java.time.Duration;

/** Tomcat riêng, cổng ngẫu nhiên, chỉ đọc dữ liệu nghiệp vụ qua các trang. */
public class WebSmokeCheck {
    static void check(boolean ok, String reason) {
        if (!ok) throw new AssertionError(reason);
    }
    public static void main(String[] args) throws Exception {
        Tomcat tomcat = new Tomcat();
        tomcat.setBaseDir(Path.of("target/tomcat-sql-check").toAbsolutePath().toString());
        tomcat.setPort(0);
        tomcat.getConnector().setProperty("address", "127.0.0.1");
        org.apache.catalina.Context webapp = tomcat.addWebapp("/check", Path.of("target/DuAnNhom1-1.0-SNAPSHOT").toAbsolutePath().toString());
        try {
            tomcat.start();
            String base = "http://127.0.0.1:" + tomcat.getConnector().getLocalPort() + "/check";
            CookieManager cookies = new CookieManager(null, CookiePolicy.ACCEPT_ALL);
            HttpClient client = HttpClient.newBuilder().cookieHandler(cookies)
                .connectTimeout(Duration.ofSeconds(10)).build();
            HttpResponse<String> login = client.send(HttpRequest.newBuilder(URI.create(base + "/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString("username=admin_quan&password=123456"))
                .timeout(Duration.ofSeconds(30)).build(), HttpResponse.BodyHandlers.ofString());
            check(login.statusCode() == 302 && login.headers().firstValue("location").orElse("").endsWith("/thong-ke"), "Login with SQL sample manager");
            String[] paths = {
                "/quan-ly-san-pham", "/quan-ly-san-pham?action=search&keyword=1",
                "/quan-ly-san-pham?action=edit&id=1", "/quan-ly-combo",
                "/quan-ly-combo?action=search&keyword=1", "/quan-ly-combo?action=edit&id=1",
                "/quan-ly-combo?action=chiTiet&id=1", "/thong-ke?from=2026-03-20&to=2026-03-20",
                "/thong-ke?mode=month&year=2026", "/thong-ke?mode=year&startYear=2025&endYear=2026"
            };
            for (String path : paths) {
                HttpResponse<String> page = client.send(HttpRequest.newBuilder(URI.create(base + path))
                    .timeout(Duration.ofSeconds(30)).GET().build(), HttpResponse.BodyHandlers.ofString());
                check(page.statusCode() == 200, path + " returned " + page.statusCode());
                if (path.equals("/quan-ly-combo?action=edit&id=1")) {
                    String html = page.body();
                    int editBody = html.indexOf("id=\"editPickerBody\"");
                    check(editBody > 0, "Edit modal rendered");
                    check(html.substring(editBody).matches("(?s).*name=\"ctMaSP\" value=\"1\"[^>]*checked.*"), "Integer-key map preserves selected combo products");
                    check(html.contains("combo_solo.png"), "Sample PNG retained");
                }
                if (path.equals("/quan-ly-san-pham?action=edit&id=1")) {
                    check(page.body().matches("(?s).*name=\"version\" value=\"[^\"]+\".*"), "Product edit carries the original version");
                }
                if (path.startsWith("/thong-ke?")) {
                    Files.writeString(Path.of("target/thong-ke-smoke.html"), page.body());
                    check(page.body().matches("(?s).*344[.,\\x{00a0}]000.*"), "Sample revenue rendered");
                    check(page.body().contains("Năm nay"), "Year filter rendered");
                    if (path.contains("mode=month"))
                        check(page.body().contains("03/2026") && page.body().contains("12/2026") && page.body().contains("Chi tiết từng tháng"), "Monthly table and chart rendered");
                    if (path.contains("mode=year"))
                        check(page.body().contains("Chi tiết từng năm"), "Yearly table rendered");
                }
                if (path.contains("action=chiTiet")) {
                    check(page.body().contains("\"maSP\":\"1\"") && page.body().contains("\"soLuong\":1"), "Detail JSON with integer identities");
                }
                System.out.println("PASS: HTTP 200 " + path);
            }
            URI productDelete = URI.create(base + "/quan-ly-san-pham?action=delete&id=1");
            HttpResponse<String> deleteGet = client.send(HttpRequest.newBuilder(productDelete).GET().build(), HttpResponse.BodyHandlers.ofString());
            check(deleteGet.statusCode() == 405, "Product delete must reject GET");
            HttpResponse<String> deleteNoToken = client.send(HttpRequest.newBuilder(productDelete).POST(HttpRequest.BodyPublishers.noBody()).build(), HttpResponse.BodyHandlers.ofString());
            check(deleteNoToken.statusCode() == 403, "Product delete must reject a POST without its session token");
            for (String bad : new String[]{"mode=year&startYear=2026&endYear=2025", "mode=year&startYear=2000&endYear=2026", "mode=month&year=abc", "mode=unknown"}) {
                HttpResponse<String> page = client.send(HttpRequest.newBuilder(URI.create(base + "/thong-ke?" + bad)).GET().build(), HttpResponse.BodyHandlers.ofString());
                check(page.statusCode() == 400 && page.body().contains("Chưa thể hiển thị báo cáo"), "Invalid filter returns helpful HTTP 400");
            }
        } finally {
            if (webapp.getLoader() != null && webapp.getLoader().getClassLoader() != null) {
                Class<?> config = webapp.getLoader().getClassLoader().loadClass("util.HibernateConfig");
                Object factory = config.getMethod("getFACTORY").invoke(null);
                factory.getClass().getMethod("close").invoke(factory);
            }
            tomcat.stop();
            tomcat.destroy();
        }
        System.out.println("PASS: login, product/combo pages, searches, edit selection, detail JSON and sample revenue on Tomcat.");
    }
}

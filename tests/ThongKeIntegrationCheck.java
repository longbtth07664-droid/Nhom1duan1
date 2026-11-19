import java.sql.*;
import java.nio.file.*;
import java.util.regex.*;
import java.lang.reflect.*;
import java.time.LocalDate;
import java.math.BigDecimal;
import entity.ThongKeReport;
import repository.ThongKeRepository;
import controller.ThongKeServlet;

// Kiểm thử tích hợp SQL bằng bảng tạm trong phiên; không sửa bảng nghiệp vụ.
public class ThongKeIntegrationCheck {
 static void check(boolean ok,String reason){if(!ok)throw new AssertionError(reason);}
 static void execute(Connection c,String sql)throws Exception {try(Statement s=c.createStatement()){s.execute(sql);}}
 public static void main(String[] args)throws Exception{
  String config=Files.readString(Path.of("src/main/java/util/HibernateConfig.java"));
  String[] keys={"URL","USER","PASS"},values=new String[3];
  for(int i=0;i<3;i++){Matcher m=Pattern.compile("Environment\\."+keys[i]+",\\s*\"([^\"]+)\"").matcher(config);if(!m.find())throw new Exception("Missing config");values[i]=m.group(1);}
  ThongKeServlet.validateRange(LocalDate.of(2024,1,1),LocalDate.of(2024,12,31));
  try{ThongKeServlet.validateRange(LocalDate.of(2026,6,3),LocalDate.of(2026,6,1));throw new AssertionError("Reversed range");}catch(IllegalArgumentException expected){}
  try{ThongKeServlet.validateRange(LocalDate.of(2024,1,1),LocalDate.of(2025,1,1));throw new AssertionError("Too long");}catch(IllegalArgumentException expected){}
  try(Connection c=DriverManager.getConnection(values[0]+"loginTimeout=5;",values[1],values[2])){
   ThongKeRepository repo=new ThongKeRepository();
   ThongKeReport live=repo.load(c,LocalDate.of(2026,3,20),LocalDate.of(2026,3,20));
   System.out.println("PASS: actual database queries; invoice count="+live.getInvoices());
   execute(c,"CREATE TABLE #tk_HoaDon (MaDatVe int,NgayDat datetime,TongTien decimal(18,0),TienGiam decimal(18,0),TrangThai nvarchar(50));"
    +"CREATE TABLE #tk_ThanhToan(MaDatVe int,TrangThai nvarchar(50));"
    +"CREATE TABLE #tk_Ve(MaDatVe int,MaSuat int,GiaVe decimal(18,0),TrangThai nvarchar(30));"
    +"CREATE TABLE #tk_ChiTietHoaDon(MaDatVe int,MaSP int,MaCombo int,SoLuong int,DonGia decimal(18,0));"
    +"CREATE TABLE #tk_SuatChieu(MaSuat int,MaPhim int);"
    +"CREATE TABLE #tk_Phim(MaPhim int,TenPhim nvarchar(200));"
    +"CREATE TABLE #tk_SanPham(MaSP int,TenSP nvarchar(100));"
    +"CREATE TABLE #tk_Combo(MaCombo int,TenCombo nvarchar(100));");
   execute(c,"INSERT INTO #tk_HoaDon VALUES "
    +"(1,'2026-06-01',180,20,N'Đã hoàn tất'),(2,'2026-06-03T23:59:59.997',70,0,N'Đã hoàn tất'),"
    +"(3,'2026-06-04',1000,0,N'Đã hoàn tất'),(4,'2026-06-01',1000,0,N'Đã hủy'),"
    +"(5,'2026-06-01',1000,0,N'Đã hoàn tất'),(6,'2026-06-01',1000,0,N'Đã hoàn tất'),"
    +"(7,'2026-06-03',5,0,N'Đã hoàn tất');"
    +"INSERT INTO #tk_ThanhToan VALUES (1,N'Thành công'),(1,N'Thành công'),(2,N'Thành công'),"
    +"(3,N'Thành công'),(4,N'Thành công'),(5,N'Thất bại'),(7,N'Thành công');"
    +"INSERT INTO #tk_Ve VALUES (1,1,50,N'Đã bán'),(1,1,50,N'Đã check-in'),(1,1,999,N'Đã hủy'),(2,1,70,N'Đã soát vé');"
    +"INSERT INTO #tk_ChiTietHoaDon VALUES (1,1,NULL,2,30),(1,NULL,1,1,40);"
    +"INSERT INTO #tk_Phim VALUES (1,N'Phim thử'); INSERT INTO #tk_SuatChieu VALUES (1,1);"
    +"INSERT INTO #tk_SanPham VALUES (1,N'Bắp'); INSERT INTO #tk_Combo VALUES (1,N'Combo');");
   // Thay tên bảng trong truy vấn bằng bảng tạm, giữ nguyên toàn bộ logic SQL production.
   Connection test=(Connection)Proxy.newProxyInstance(ThongKeIntegrationCheck.class.getClassLoader(),new Class[]{Connection.class},(proxy,method,params)->{
    // Hàm đọc không được can thiệp giao dịch hoặc cấu hình của bên gọi.
    if(java.util.Set.of("commit", "rollback", "close", "setAutoCommit", "setTransactionIsolation").contains(method.getName()))
     throw new AssertionError("Report changed caller connection: " + method.getName());
    if(method.getName().equals("prepareStatement") && params[0] instanceof String){
     String sql=(String)params[0];
     for(String name:new String[]{"HoaDon","ThanhToan","Ve","ChiTietHoaDon","SuatChieu","Phim","SanPham","Combo"})
      sql=sql.replaceAll("\\b"+name+"\\b","#tk_"+name);
     params[0]=sql;
    }
    try{return method.invoke(c,params);}catch(InvocationTargetException e){throw e.getCause();}
   });
   ThongKeReport r=repo.load(test,LocalDate.of(2026,6,1),LocalDate.of(2026,6,3));
   check(r.getRevenue().compareTo(new BigDecimal("255"))==0,"No duplicate invoice revenue");
   check(r.getInvoices()==3 && r.getTickets()==3 && r.getItems()==3,"Counts and cancelled/unpaid filtering");
   check(r.getDiscount().intValueExact()==20,"Discount counted once");
   check(r.getTicketValue().intValueExact()==170 && r.getProductValue().intValueExact()==100,"Independent detail aggregation");
   check(r.getDays().size()==3 && r.getDays().get(1).getInvoices()==0,"Fill missing days");
   check(r.getDays().get(2).getRevenue().intValueExact()==75,"Inclusive final day");
   check(r.getMismatches()==1 && r.getAverage().intValueExact()==85,"Reconciliation and average");
   check(r.getFilms().size()==1 && r.getFilms().get(0).getValue().intValueExact()==170,"Film ranking");
   check(r.getProducts().size()==2 && r.getProducts().get(0).getValue().intValueExact()==60,"Product ranking");
   check(r.getDays().get(0).getHeight()==100,"Chart normalization");
   // Hai hóa đơn trong file SQL người dùng, dùng đúng khóa INT.
   execute(c,"INSERT INTO #tk_HoaDon VALUES (101,'2026-03-20T08:30:00',139000,16000,N'Đã hoàn tất'),"
    +"(102,'2026-03-20T08:45:00',205000,0,N'Đã hoàn tất');"
    +"INSERT INTO #tk_ThanhToan VALUES (101,N'Thành công'),(102,N'Thành công');"
    +"INSERT INTO #tk_Ve VALUES (101,1,80000,N'Đã in'),(102,1,95000,N'Đã in');"
    +"INSERT INTO #tk_ChiTietHoaDon VALUES (101,NULL,1,1,75000),(102,NULL,2,1,110000);"
    +"INSERT INTO #tk_Combo VALUES (2,N'Combo Couple');");
   ThongKeReport sample=repo.load(test,LocalDate.of(2026,3,20),LocalDate.of(2026,3,20));
   check(sample.getRevenue().intValueExact()==344000 && sample.getDiscount().intValueExact()==16000,"Sample net revenue: do not discount twice");
   check(sample.getTicketValue().intValueExact()==175000 && sample.getProductValue().intValueExact()==185000,"Sample ticket and combo values");
   check(sample.getInvoices()==2 && sample.getTickets()==2 && sample.getItems()==2 && sample.getMismatches()==0,"Sample counts and reconciliation");
   ThongKeReport allDays=repo.load(test,LocalDate.of(2026,1,1),LocalDate.of(2026,12,31));
   ThongKeReport months=allDays.groupBy("month");
   check(months.getDays().size()==12,"Always show 12 months including empty months");
   check(months.getDays().get(2).getDate().equals("03/2026") && months.getDays().get(2).getRevenue().intValueExact()==344000,"March bucket and label");
   check(months.getDays().get(0).getInvoices()==0,"Empty month is zero");
   check(months.getRevenue().compareTo(allDays.getRevenue())==0 && months.getMismatches()==allDays.getMismatches(),"Grouping preserves revenue and reconciliation");
   check(months.getTickets()==allDays.getTickets() && months.getItems()==allDays.getItems() && months.getDiscount().equals(allDays.getDiscount()),"Grouping preserves quantities and discount");
   check(months.getFilms().size()==allDays.getFilms().size() && months.getProducts().size()==allDays.getProducts().size(),"Rankings use same period");
   ThongKeReport years=repo.load(test,LocalDate.of(2025,1,1),LocalDate.of(2026,12,31)).groupBy("year");
   check(years.getDays().size()==2 && years.getDays().get(0).getDate().equals("2025") && years.getDays().get(0).getRevenue().signum()==0,"Empty year and year label");
   check(years.getDays().get(1).getRevenue().compareTo(allDays.getRevenue())==0,"Year totals equal daily totals");
   ThongKeServlet.validateRange(LocalDate.of(2024,1,1),LocalDate.of(2024,12,31),"month");
   ThongKeServlet.validateRange(LocalDate.of(2017,1,1),LocalDate.of(2026,12,31),"year");
   for(String mode:new String[]{"year","invalid"}) {
    try {ThongKeServlet.validateRange(LocalDate.of(2016,1,1),LocalDate.of(2026,12,31),mode);throw new AssertionError("Invalid mode/range accepted");}
    catch(IllegalArgumentException expected) {}
   }
   check(repo.load(test,LocalDate.of(2024,1,1),LocalDate.of(2024,12,31)).groupBy("month").getDays().size()==12,"Leap year has exactly 12 monthly buckets");
   System.out.println("PASS: monthly/yearly aggregation, empty periods, leap year, range limits, same totals and rankings.");
   ThongKeReport empty=repo.load(test,LocalDate.of(2020,1,1),LocalDate.of(2020,1,2));
   check(empty.isEmpty() && empty.getAverage().signum()==0 && empty.getDays().size()==2,"Empty result");
   // Tạo thay đổi chưa commit trên bảng tạm rồi gọi báo cáo.
   // Nếu báo cáo tự commit, rollback bên dưới sẽ không xóa được dòng thử.
   execute(c,"CREATE TABLE #tk_TransactionMarker(Id int)");
   c.setAutoCommit(false);
   int originalIsolation = c.getTransactionIsolation();
   execute(c,"INSERT INTO #tk_TransactionMarker VALUES (1)");
   repo.load(test,LocalDate.of(2026,6,1),LocalDate.of(2026,6,3));
   check(!c.getAutoCommit() && c.getTransactionIsolation()==originalIsolation,"Preserve caller connection settings");
   c.rollback();
   try(Statement statement=c.createStatement(); ResultSet rows=statement.executeQuery("SELECT COUNT(*) FROM #tk_TransactionMarker")) {
    rows.next(); check(rows.getInt(1)==0,"Report must not commit caller transaction");
   }
   // Khi SQL lỗi, báo cáo cũng không được rollback thay bên gọi.
   execute(c,"INSERT INTO #tk_TransactionMarker VALUES (2)");
   Connection broken=(Connection)Proxy.newProxyInstance(ThongKeIntegrationCheck.class.getClassLoader(),new Class[]{Connection.class},(proxy,method,params)->{
    if(method.getName().equals("prepareStatement")) throw new SQLException("Simulated query failure");
    try{return method.invoke(test,params);}catch(InvocationTargetException e){throw e.getCause();}
   });
   try {repo.load(broken,LocalDate.of(2026,6,1),LocalDate.of(2026,6,3)); throw new AssertionError("Expected query failure");}
   catch(SQLException expected) {}
   try(Statement statement=c.createStatement(); ResultSet rows=statement.executeQuery("SELECT COUNT(*) FROM #tk_TransactionMarker")) {
    rows.next(); check(rows.getInt(1)==1,"Report must not rollback caller transaction on failure");
   }
   c.rollback();
   c.setAutoCommit(true);
   System.out.println("PASS: caller transaction remains unchanged on success and SQL failure.");
   System.out.println("PASS: duplicate payments, multiple tickets/items, paid status, cancellation, date boundaries, empty days, ranking, reconciliation, date validation.");
  }
 }
}

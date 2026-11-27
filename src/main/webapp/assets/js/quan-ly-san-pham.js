// [SP-JS] Xử lý thao tác trên giao diện. Kiểm tra và lưu thật nằm ở Servlet/Repository.
// SẢN PHẨM: gợi ý đơn vị theo loại, không đổi các giá trị dữ liệu hiện có.
// [SP-GOI-Y] Gợi ý đơn vị tính khi đổi loại sản phẩm.
function goiYDonVi(select) {
    var units = {"Bắp":"Hộp", "Nước có gas":"Ly", "Nước suối":"Chai", "Snack":"Gói", "Đồ ăn nóng":"Hộp"};
    select.form.elements.donViTinh.value = units[select.value] || "";
}
// [SP-XAC-NHAN-XOA] Xác nhận rồi gửi form POST xóa.
function xoaSP(btn) {
    var ma = btn.getAttribute('data-ma');
    var ten = btn.getAttribute('data-ten');
    if (confirm('Bạn có chắc muốn xóa sản phẩm "' + ten + '" (' + ma + ') không?')) {
        var form = document.getElementById('deleteProductForm');
        form.elements.namedItem('id').value = ma;
        form.submit();
    }
}

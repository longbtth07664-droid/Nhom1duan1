// [SP-JS] Xử lý thao tác trên giao diện. Kiểm tra và lưu thật nằm ở Servlet/Repository.
// [SP-GOI-Y] Chọn loại Bắp thì đoạn nào tự điền đơn vị Hộp?
// goiYDonVi tra loại đang chọn trong units, rồi gán vào ô donViTinh trên cùng form.
function goiYDonVi(select) {
    var units = {"Bắp":"Hộp", "Nước có gas":"Ly", "Nước suối":"Chai", "Snack":"Gói", "Đồ ăn nóng":"Hộp"};
    select.form.elements.donViTinh.value = units[select.value] || "";
}
// [SP-XAC-NHAN-XOA] Bấm Xóa sản phẩm thì đoạn nào hỏi lại và gửi mã?
// confirm hỏi xác nhận. Nếu đồng ý, hàm điền mã vào deleteProductForm rồi gọi form.submit().
// Điều kiện chặn xóa sản phẩm đang được dùng nằm ở Java, mã [SP-DA-SU-DUNG].
function xoaSP(btn) {
    var ma = btn.getAttribute('data-ma');
    var ten = btn.getAttribute('data-ten');
    if (confirm('Bạn có chắc muốn xóa sản phẩm "' + ten + '" (' + ma + ') không?')) {
        var form = document.getElementById('deleteProductForm');
        form.elements.namedItem('id').value = ma;
        form.submit();
    }
}

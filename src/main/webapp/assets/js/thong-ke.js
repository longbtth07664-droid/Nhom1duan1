// [TK-JS] Xử lý thao tác trên giao diện. Kiểm tra và lưu thật nằm ở Servlet/Repository.
// [TK-DOICHE DO] Chỉ gửi các ô thuộc chế độ đang chọn, tránh required ở ô ẩn.
// [TK-DOI-CHE-DO] Hiện ô thuộc chế độ đang chọn, vô hiệu hóa ô thuộc chế độ khác.
function doiCheDoThongKe() {
    var mode = document.getElementById('tkMode').value;
    var groups = document.querySelectorAll('[data-mode]');
    for (var i = 0; i < groups.length; i++) {
        var active = groups[i].getAttribute('data-mode') === mode;
        groups[i].hidden = !active;
        groups[i].style.display = active ? '' : 'none';
        var inputs = groups[i].querySelectorAll('input');
        for (var j = 0; j < inputs.length; j++) inputs[j].disabled = !active;
    }
}
doiCheDoThongKe();
// Menu dùng riêng tại trang này, giữ nguyên mã menu của các module khác.
function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('open');
}
function toggleSubmenu(button) {
    button.closest('.nav-group').classList.toggle('open');
}

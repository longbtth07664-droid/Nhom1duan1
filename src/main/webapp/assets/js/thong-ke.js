// [TK-DOI-CHE-DO] Chọn Ngày, Tháng hoặc Năm thì đoạn nào đổi ô nhập?
// doiCheDoThongKe so tkMode với data-mode của từng nhóm rồi hiện đúng nhóm đang chọn.
// Chỉ inputs[j].disabled = !active: ô của nhóm khác không được gửi và không bị kiểm tra required.
// Khi gửi form, ThongKeServlet kiểm tra khoảng thời gian và ThongKeRepository lấy số liệu.
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
// [TK-MENU] Bấm nút menu thì đoạn nào đóng hoặc mở thanh bên?
// toggleSidebar đổi class open của thanh bên. toggleSubmenu đổi class open của nhóm chứa nút.
function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('open');
}
function toggleSubmenu(button) {
    button.closest('.nav-group').classList.toggle('open');
}

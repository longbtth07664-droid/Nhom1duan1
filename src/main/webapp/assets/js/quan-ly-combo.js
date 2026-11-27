// [CB-JS] Xử lý thao tác trên giao diện. Kiểm tra và lưu thật nằm ở Servlet/Repository.
// [CB-CHON-MON] Tích chọn món thì đoạn nào bật ô số lượng và ghi chú?
// Chỉ vào inputs[i].disabled = !checkbox.checked. Ô được bật khi món đã tích, sau đó hàm tính lại giá xem trước.
function toggleProductRow(checkbox, mode) {
    var row = checkbox.closest('tr');
    var inputs = row.querySelectorAll('input[type="number"], input[type="text"]');
    for (var i = 0; i < inputs.length; i++) {
        inputs[i].disabled = !checkbox.checked;
    }
    row.classList.toggle('sp-row-active', checkbox.checked);
    tinhTongGiaLe(mode);
}


// [CB-LOC-MON] Gõ tên món thì đoạn nào lọc danh sách? Món bị ẩn còn được chọn không?
// Chỉ vào row.hidden. Hàm so chuỗi đã bỏ dấu và chỉ ẩn dòng, nên ô đã tích vẫn giữ nguyên.
function locSanPham(mode, text) {
    var keyword = boDauTiengViet(text.trim());
    var count = 0;
    var rows = document.querySelectorAll('#' + mode + 'PickerBody tr');
    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        row.hidden = !boDauTiengViet(row.textContent).includes(keyword);
        if (!row.hidden) count++;
    }
    document.getElementById(mode + 'Empty').hidden = count > 0;
}

// [CB-BO-DAU] Vì sao gõ "bap" vẫn tìm được "Bắp"?
// normalize('NFD') tách dấu để replace xóa dấu. Hàm cũng đưa về chữ thường và đổi đ thành d.
function boDauTiengViet(text) {
    return text.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');
}
// [CB-GIA-XEM-TRUOC] Giá combo trên màn hình được tính ở đâu?
// Chỉ vào total += giá × số lượng và Math.round. Hàm cộng món đã tích, kể cả món bị ẩn, rồi áp dụng mức giảm.
// rate = -1 thì hiện giá cũ. Giá ghi vào database được tính ở ComboRepository, mã [CB-GIAM-GIA].
function tinhTongGiaLe(mode) {
    var body=document.getElementById(mode+'PickerBody');
    if(!body) return;
    var total=0;
    var selected = body.querySelectorAll('input[type="checkbox"]:checked');
    for (var i = 0; i < selected.length; i++) {
        var cb = selected[i];
        var qty=Number(cb.closest('tr').querySelector('input[type="number"]').value);
        if(Number.isInteger(qty)&&qty>0) total+=Number(cb.dataset.gia)*qty;
    }
    document.getElementById(mode+'TongGiaLe').textContent='Tổng giá lẻ: '+total.toLocaleString('vi-VN')+' đ';
    var price=document.getElementById(mode+'GiaCombo');
    var rate=Number(document.getElementById(mode+'GiamGia').value);
    if (rate === -1) {
        price.value = price.dataset.original;
    } else {
        price.value = Math.round(total * (100 - rate) / 100);
    }
}
// [CB-KIEM-TRA-FORM] Trước khi gửi form, đoạn nào chặn quên chọn món hoặc nhập số lượng sai?
// Chỉ vào các nhánh return false. Phải chọn ít nhất một món, số lượng là số nguyên dương.
// Combo đang bán còn phải đủ tồn và món đang kinh doanh. Server kiểm tra lại khi lưu.
function validateComboForm(mode) {
    var form = document.getElementById(mode + 'GiaCombo').form;
    var dangBan = mode === 'add' || form.elements.trangThai.value === 'Đang bán';
    var items = form.querySelectorAll('input[name="ctMaSP"]:checked');
    if(!items.length) { alert('Hãy chọn ít nhất một sản phẩm.'); return false; }
    for (var i = 0; i < items.length; i++) {
        var cb = items[i];
        var qty=Number(cb.closest('tr').querySelector('input[type="number"]').value);
        if (!Number.isInteger(qty) || qty < 1 || qty > 2147483647) {
            alert('Số lượng phải là số nguyên dương hợp lệ.');
            return false;
        }
        // [CB-NGUNG-BAN] Được giữ thành phần cũ khi tắt combo đã hết nguyên liệu.
        if (dangBan && (qty > Number(cb.dataset.stock) || cb.dataset.active !== 'true')) {
            alert('Sản phẩm '+cb.value+': số lượng phải từ 1 đến '+cb.dataset.stock+' và còn kinh doanh.');
            return false;
        }
    }
    tinhTongGiaLe(mode);
    // [CB-LUU-NHAP] Bản nháp được lưu trước khi gửi form ở đâu?
    // FormData đọc các trường đã nhập. sessionStorage giữ phần dạng chuỗi trong tab, ảnh phải chọn lại.
    try {
        // Trình duyệt yêu cầu chọn lại tệp sau khi trang tải lại. Chỉ giữ các ô văn bản.
        var fields = [];
        for (var pair of new FormData(form).entries()) {
            if (typeof pair[1] === 'string') fields.push(pair);
        }
        sessionStorage.setItem('comboDraft', JSON.stringify(fields));
    } catch(e) {}
    return true;
}
document.addEventListener('DOMContentLoaded',function() {
    khoiTaoBangSanPham('add');
    khoiTaoBangSanPham('edit');
    // Hàm riêng giữ đúng mode cho sự kiện của từng bảng.
    function khoiTaoBangSanPham(mode) {
        var body=document.getElementById(mode+'PickerBody');
        if(!body) return;
        body.addEventListener('invalid',function(e){e.target.closest('tr').hidden=false;},true);
        // [CB-GIU-GIA] Khi nào form tự bỏ chế độ giữ giá cũ?
        // Sự kiện input chỉ xử lý checkbox và ô số lượng. rate.value từ -1 chuyển về 0 rồi tính lại.
        body.addEventListener('input',function(event){
            var type = event.target.type;
            if (type !== 'checkbox' && type !== 'number') return;
            var rate=document.getElementById(mode+'GiamGia');
            if(rate.value==='-1') rate.value='0';
            tinhTongGiaLe(mode);
        });
        tinhTongGiaLe(mode);
    }
    // [CB-KHOI-PHUC-NHAP] Nếu server báo lỗi thì đoạn nào điền lại dữ liệu?
    // msg=error tải comboDraft. Form sửa chỉ khôi phục khi đúng mã combo và version đang mở.
    try {
        var params=new URLSearchParams(location.search);
        if(params.get('msg')==='error') {
            var entries=JSON.parse(sessionStorage.getItem('comboDraft')||'[]');
            var action=timTruongBanNhap(entries, 'action');
            var mode=action&&action[1]==='add'?'add':'edit';
            var price=document.getElementById(mode+'GiaCombo');
            if(!price) return;
            var form=price.form;
            // Bản nháp chỉ áp dụng cho đúng combo và đúng dữ liệu lúc mở form.
            if (mode === 'edit') {
                var draftId = timTruongBanNhap(entries, 'maCombo');
                var draftVersion = timTruongBanNhap(entries, 'version');
                if (!draftId || !draftVersion || draftId[1] !== form.elements.maCombo.value
                        || draftVersion[1] !== form.elements.version.value) return;
            }
            // Khôi phục từng ô; giữ nguyên token, mã và phiên bản hiện tại.
            var boxes = form.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < boxes.length; i++) {
                boxes[i].checked = false;
                toggleProductRow(boxes[i], mode);
            }
            for (var i = 0; i < entries.length; i++) {
                var pair = entries[i];
                for (var j = 0; j < form.elements.length; j++) {
                    var el = form.elements[j];
                    if (el.name !== pair[0]) continue;
                    if (el.type === 'checkbox') {
                        if (el.value === pair[1]) {
                            el.checked = true;
                            toggleProductRow(el, mode);
                        }
                    } else if (el.type !== 'file' && el.name !== 'token'
                            && el.name !== 'version' && el.name !== 'maCombo') {
                        el.value = pair[1];
                    }
                }
            }
            tinhTongGiaLe(mode); openModal(mode+'ComboModal');
        } else if(params.get('msg')) sessionStorage.removeItem('comboDraft');
    } catch(e) { /* Không có bản nháp thì giữ form mặc định. */ }
});

// [CB-BAN-NHAP] Code nào tìm action, maCombo hoặc version trong bản nháp?
// timTruongBanNhap duyệt các cặp tên và giá trị, rồi trả cặp đầu tiên có tên cần tìm.
function timTruongBanNhap(entries, name) {
    for (var i = 0; i < entries.length; i++) {
        if (entries[i][0] === name) return entries[i];
    }
    return undefined;
}
// Mở modal Chi tiết và đổ dữ liệu an toàn
var detailRequest=0; // Bỏ phản hồi cũ khi chuyển combo.
// [CB-XEM-CHI-TIET] Bấm Xem chi tiết thì code nào lấy món và đưa lên bảng?
// Chỉ vào fetch gửi action=chiTiet và id, rồi vòng lặp tạo từng ô từ JSON. textContent hiển thị dữ liệu dạng văn bản.
// requestId giúp bỏ phản hồi đến trễ nếu người dùng đã bấm xem combo khác.
function xemChiTietCombo(btn) {
    var requestId=++detailRequest;
    var ma = btn.getAttribute('data-ma') || '';
    document.getElementById('dtMaCombo').textContent = ma;
    document.getElementById('dtTenCombo').textContent = btn.getAttribute('data-ten') || '';
    document.getElementById('dtGiaCombo').textContent = btn.getAttribute('data-gia') || '';
    var anh = document.getElementById('dtHinhAnh');
    var urlAnh = btn.getAttribute('data-anh');
    anh.hidden = !urlAnh;
    document.getElementById('dtChuaCoAnh').hidden = !!urlAnh;
    if (urlAnh) anh.src = urlAnh;
    else anh.removeAttribute('src');
    document.getElementById('dtMoTa').textContent = btn.getAttribute('data-mota') || '';

    var tbody = document.getElementById('detailComboBody');
    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;">Đang tải...</td></tr>';
    openModal('detailComboModal');

    fetch(document.getElementById('deleteComboForm').action + '?action=chiTiet&id=' + encodeURIComponent(ma))
        .then(function (res) { if(!res.ok) throw new Error("Không tải được chi tiết"); return res.json(); })
        .then(function (data) {
            if(requestId!==detailRequest) return;
            tbody.innerHTML = '';
            if (data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:var(--text-secondary);">Chưa có sản phẩm nào trong combo này.</td></tr>';
                return;
            }
            for (var i = 0; i < data.length; i++) {
                var ct = data[i];
                var tr = document.createElement('tr');
                var cols = [
                    ct.maSP,
                    ct.tenSP,
                    ct.donViTinh,
                    String(ct.soLuong),
                    Number(ct.giaBan).toLocaleString('vi-VN') + ' đ',
                    ct.ghiChu || ''
                ];
                for (var j = 0; j < cols.length; j++) {
                    var val = cols[j];
                    var td = document.createElement('td');
                    td.textContent = val;
                    tr.appendChild(td);
                }
                tbody.appendChild(tr);
            }
        })
        .catch(function (err) {
            if(requestId!==detailRequest) return;
            console.error(err);
            tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#DC2626;">Lỗi tải chi tiết combo!</td></tr>';
        });
}

// [CB-XAC-NHAN-XOA] Bấm Xóa combo thì trình duyệt làm gì?
// confirm hỏi lại. Nếu đồng ý, hàm gán mã vào form và gọi form.submit(). Repository quyết định có được xóa hay không.
function xoaCombo(btn) {
    var ma = btn.getAttribute('data-ma');
    var ten = btn.getAttribute('data-ten');
    if (confirm('Bạn có chắc muốn xóa combo "' + ten + '" (' + ma + ') không?')) {
        var form = document.getElementById('deleteComboForm');
        form.elements.namedItem('id').value = ma;
        form.submit();
    }
}


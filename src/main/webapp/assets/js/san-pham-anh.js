// [SP-ANH-KHOI-TAO] Chỉ gắn sự kiện cho ô ảnh sản phẩm, không đổi giao diện combo.
document.addEventListener('DOMContentLoaded', function () {
    var inputs = document.querySelectorAll('input[data-sp-anh]');
    for (var i = 0; i < inputs.length; i++) {
        khoiTaoAnhSanPham(inputs[i]);
    }
});

function khoiTaoAnhSanPham(input) {
    var group = input.closest('.form-group');
    var button = group.querySelector('[data-sp-chon-anh]');
    var name = group.querySelector('.anh-danh-muc-ten');
    var preview = group.querySelector('.anh-danh-muc-xem-truoc');
    var original = preview.getAttribute('src');
    var originalHidden = preview.hidden;
    var originalName = name.textContent;
    var temporaryUrl = null;

    // [SP-ANH-CHON] Nút Thêm ảnh mở hộp chọn tệp của máy tính.
    input.hidden = true;
    button.addEventListener('click', function () {
        input.click();
    });

    // [SP-ANH-XEM-TRUOC] Kiểm tra tệp và hiện ảnh vừa chọn, chưa ghi vào database.
    input.addEventListener('change', capNhatAnhSanPham);

    // Hàm nằm trong khoiTaoAnhSanPham để mỗi form giữ riêng ảnh gốc và URL tạm.
    function capNhatAnhSanPham() {
        var file = input.files[0];
        if (file && (file.size > 5 * 1024 * 1024
                || (file.type !== 'image/jpeg' && file.type !== 'image/png'))) {
            alert('Hãy chọn ảnh JPG hoặc PNG, tối đa 5 MB.');
            input.value = '';
            file = null;
        }
        if (temporaryUrl !== null) {
            URL.revokeObjectURL(temporaryUrl);
            temporaryUrl = null;
        }
        if (file) {
            name.textContent = file.name;
            temporaryUrl = URL.createObjectURL(file);
            preview.src = temporaryUrl;
            preview.hidden = false;
        } else {
            // Bỏ lựa chọn thì trở về ảnh cũ; không gửi tên ảnh giả từ trình duyệt.
            name.textContent = originalName;
            if (original) preview.src = original;
            else preview.removeAttribute('src');
            preview.hidden = originalHidden;
        }
    }
}

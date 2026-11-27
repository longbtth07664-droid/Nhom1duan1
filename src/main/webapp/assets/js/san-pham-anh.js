// [SP-ANH-KHOI-TAO] Trình duyệt tìm ô ảnh sản phẩm ở đâu?
// Khi trang sẵn sàng, querySelectorAll tìm input có data-sp-anh rồi gọi khoiTaoAnhSanPham cho từng ô.
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

    // [SP-ANH-CHON] Nút Thêm ảnh mở hộp chọn tệp ở dòng nào?
    // Sự kiện click gọi input.click() để mở hộp chọn tệp của trình duyệt.
    input.hidden = true;
    button.addEventListener('click', function () {
        input.click();
    });

    input.addEventListener('change', capNhatAnhSanPham);

    // [SP-ANH-XEM-TRUOC] Đoạn nào kiểm tra và xem trước ảnh sản phẩm?
    // capNhatAnhSanPham kiểm tra JPG/PNG tối đa 5 MB. createObjectURL tạo địa chỉ tạm gán vào preview.src.
    // Nếu ô chọn tệp trống hoặc tệp bị từ chối thì hiện lại ảnh gốc của form.
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

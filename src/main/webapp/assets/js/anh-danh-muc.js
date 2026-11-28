/**
 * Xử lý xem trước ảnh tải lên cho danh mục Sản phẩm & Combo
 */
document.addEventListener('DOMContentLoaded', function () {
    var inputs = document.querySelectorAll('input[type="file"][name="tepAnh"]');
    for (var i = 0; i < inputs.length; i++) {
        khoiTaoAnhCombo(inputs[i]);
    }
});

// [CB-ANH-XEM-TRUOC] Đoạn nào hiển thị ảnh combo vừa chọn?
// khoiTaoAnhCombo gắn sự kiện change cho ô tepAnh. Chỉ createObjectURL và dòng gán previewImg.src.
// Khi đổi ảnh, revokeObjectURL giải phóng địa chỉ tạm trước đó. Việc lưu ảnh diễn ra khi gửi form.
function khoiTaoAnhCombo(input) {
        var container = input.closest('.form-group') || input.parentElement;
        if (!container) return;
        var button = container.querySelector('[data-anh-control] button');
        // [CB-ANH-CHON] Bấm + Thêm ảnh gọi click trên ô tệp đã ẩn của đúng form.
        if (button) {
            button.addEventListener('click', function () {
                input.click();
            });
        }
        var temporaryUrl = null;
        input.addEventListener('change', function () {
            var file = this.files && this.files[0];
            var nameSpan = container.querySelector('.anh-danh-muc-ten');
            var previewImg = container.querySelector('.anh-danh-muc-xem-truoc');
            if (temporaryUrl) URL.revokeObjectURL(temporaryUrl);
            temporaryUrl = null;
            if (file) {
                if (nameSpan) nameSpan.textContent = file.name;
                if (previewImg) {
                    temporaryUrl = URL.createObjectURL(file);
                    previewImg.src = temporaryUrl;
                    previewImg.removeAttribute('hidden');
                    previewImg.style.display = 'block';
                }
            } else {
                if (nameSpan) nameSpan.textContent = 'Chưa chọn tệp';
                if (previewImg) {
                    previewImg.removeAttribute('src');
                    previewImg.hidden = true;
                    previewImg.style.display = 'none';
                }
            }
        });
}

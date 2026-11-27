/**
 * Xử lý xem trước ảnh tải lên cho danh mục Sản phẩm & Combo
 */
document.addEventListener('DOMContentLoaded', function () {
    var inputs = document.querySelectorAll('input[type="file"][name="tepAnh"]');
    for (var i = 0; i < inputs.length; i++) {
        khoiTaoAnhCombo(inputs[i]);
    }
});

// [CB-ANH-XEM-TRUOC] Mỗi ô file có hàm riêng, dùng vòng for để gắn sự kiện.
function khoiTaoAnhCombo(input) {
        var temporaryUrl = null;
        input.addEventListener('change', function () {
            var file = this.files && this.files[0];
            var container = this.closest('.form-group') || this.parentElement;
            if (!container) return;
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

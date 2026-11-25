/**
 * Xử lý xem trước ảnh tải lên cho danh mục Sản phẩm & Combo
 */
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('input[type="file"][name="tepAnh"]').forEach(function (input) {
        input.addEventListener('change', function () {
            var file = this.files && this.files[0];
            var container = this.closest('.form-group') || this.parentElement;
            if (!container) return;
            var nameSpan = container.querySelector('.anh-danh-muc-ten');
            var previewImg = container.querySelector('.anh-danh-muc-xem-truoc');
            if (file) {
                if (nameSpan) nameSpan.textContent = file.name;
                if (previewImg) {
                    previewImg.src = URL.createObjectURL(file);
                    previewImg.removeAttribute('hidden');
                    previewImg.style.display = 'block';
                }
            } else {
                if (nameSpan) nameSpan.textContent = 'Chưa chọn tệp';
            }
        });
    });
});

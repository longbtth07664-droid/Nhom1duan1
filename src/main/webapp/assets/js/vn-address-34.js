/**
 * Helper load 34 Tỉnh/Thành phố mới của Việt Nam (Hành chính 2 cấp)
 * Hỗ trợ Hybrid: gọi API v2 (timeout 2.5s) -> tự động fallback về JSON nội bộ nếu lỗi/mất mạng.
 */
window.initVnAddress34 = function (opts) {
    const contextPath = opts.contextPath || '';
    const provinceSelect = document.getElementById(opts.provinceSelectId);
    const wardSelect = document.getElementById(opts.wardSelectId);
    const detailInput = document.getElementById(opts.detailInputId);
    const hiddenInput = document.getElementById(opts.hiddenInputId);
    const initialAddress = (opts.initialAddress || '').trim();

    if (!provinceSelect || !hiddenInput) return;

    let provincesCache = [];

    function syncHiddenAddress() {
        const prov = provinceSelect.value ? provinceSelect.options[provinceSelect.selectedIndex].text : '';
        const ward = (wardSelect && wardSelect.value) ? wardSelect.value : '';
        const detail = detailInput ? detailInput.value.trim() : '';

        const parts = [];
        if (detail) parts.push(detail);
        if (ward) parts.push(ward);
        if (prov && provinceSelect.value) parts.push(prov);
        hiddenInput.value = parts.join(', ');
    }

    function populateProvinces(list) {
        provincesCache = list || [];
        provinceSelect.innerHTML = '<option value="">-- Chọn Tỉnh / Thành phố (34 mới) --</option>';
        provincesCache.forEach(p => {
            const opt = document.createElement('option');
            opt.value = p.code;
            opt.textContent = p.name;
            provinceSelect.appendChild(opt);
        });

        // Tự động khớp địa chỉ cũ nếu đang ở màn hình Sửa
        if (initialAddress) {
            const matched = provincesCache.find(p =>
                initialAddress.toLowerCase().includes(p.name.toLowerCase()) ||
                initialAddress.toLowerCase().includes(p.name.replace(/^(Thành phố|Tỉnh)\s+/i, '').toLowerCase())
            );
            if (matched) {
                provinceSelect.value = matched.code;
                const stripped = initialAddress
                    .replace(new RegExp(',?\\s*' + matched.name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$', 'i'), '')
                    .replace(new RegExp(',?\\s*' + matched.name.replace(/^(Thành phố|Tỉnh)\s+/i, '').replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$', 'i'), '')
                    .trim();
                if (detailInput && stripped) detailInput.value = stripped;
                loadWards(matched.code);
            } else if (detailInput) {
                detailInput.value = initialAddress;
            }
        }
        syncHiddenAddress();
    }

    function loadWards(provinceCode) {
        if (!wardSelect) return;
        if (!provinceCode) {
            wardSelect.innerHTML = '<option value="">-- Chọn Phường / Xã (nếu có) --</option>';
            return;
        }
        wardSelect.innerHTML = '<option value="">-- Đang tải Phường / Xã... --</option>';
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), 2500);

        fetch('https://provinces.open-api.vn/api/v2/p/' + encodeURIComponent(provinceCode) + '?depth=2', { signal: controller.signal })
            .then(res => res.ok ? res.json() : Promise.reject())
            .then(data => {
                clearTimeout(timer);
                const wards = data.wards || [];
                wardSelect.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';
                wards.forEach(w => {
                    const opt = document.createElement('option');
                    opt.value = w.name;
                    opt.textContent = w.name;
                    wardSelect.appendChild(opt);
                });
            })
            .catch(() => {
                clearTimeout(timer);
                wardSelect.innerHTML = '<option value="">-- Nhập Phường/Xã ở ô chi tiết --</option>';
            });
    }

    // Gọi API v2 trước, fallback về JSON 34 tỉnh nội bộ
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 2500);

    fetch('https://provinces.open-api.vn/api/v2/p/', { signal: controller.signal })
        .then(res => res.ok ? res.json() : Promise.reject())
        .then(data => {
            clearTimeout(timer);
            if (Array.isArray(data) && data.length === 34) {
                populateProvinces(data.map(x => ({ code: String(x.code), name: x.name })));
            } else {
                return Promise.reject();
            }
        })
        .catch(() => {
            clearTimeout(timer);
            fetch(contextPath + '/assets/data/vietnam-34-provinces.json')
                .then(r => r.json())
                .then(populateProvinces)
                .catch(console.error);
        });

    provinceSelect.addEventListener('change', function () {
        loadWards(this.value);
        syncHiddenAddress();
    });
    if (wardSelect) wardSelect.addEventListener('change', syncHiddenAddress);
    if (detailInput) detailInput.addEventListener('input', syncHiddenAddress);

    const form = hiddenInput.closest('form');
    if (form) {
        form.addEventListener('submit', syncHiddenAddress);
    }
};

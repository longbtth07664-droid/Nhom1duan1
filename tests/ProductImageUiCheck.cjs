// Kiểm tra chọn ảnh, ảnh quá lớn, sai định dạng và trở về ảnh cũ bằng DOM giả lập.
const fs = require('fs');
const vm = require('vm');
const assert = require('assert');
const source = fs.readFileSync('src/main/webapp/assets/js/san-pham-anh.js', 'utf8');
function fixture(oldImage) {
    const events = {};
    const button = {addEventListener: (name, fn) => { events[name] = fn; }};
    const name = {textContent: 'Chưa chọn tệp mới'};
    const preview = {
        src: oldImage, hidden: !oldImage,
        getAttribute: () => oldImage,
        removeAttribute() { this.src = null; }
    };
    const input = {
        files: [], value: '', click() { this.clicked = true; },
        addEventListener: (name, fn) => { events[name] = fn; },
        closest: () => ({querySelector: selector => {
            if (selector === '[data-sp-chon-anh]') return button;
            if (selector === '.anh-danh-muc-ten') return name;
            return preview;
        }})
    };
    const alerts = [], revoked = [];
    const context = {document: {addEventListener() {}}, alert: text => alerts.push(text),
        URL: {createObjectURL: () => 'blob:test', revokeObjectURL: url => revoked.push(url)}};
    vm.createContext(context);
    vm.runInContext(source, context);
    context.khoiTaoAnhSanPham(input);
    events.click(); assert(input.clicked);
    function select(file) { input.files = file ? [file] : []; events.change(); }
    select({name: 'bap.png', size: 100, type: 'image/png'});
    assert.strictEqual(name.textContent, 'bap.png');
    assert.strictEqual(preview.src, 'blob:test'); assert.strictEqual(preview.hidden, false);
    select(null);
    assert.strictEqual(preview.src, oldImage); assert.strictEqual(preview.hidden, !oldImage);
    assert.deepStrictEqual(revoked, ['blob:test']);
    select({name: 'large.jpg', size: 5 * 1024 * 1024 + 1, type: 'image/jpeg'});
    select({name: 'file.pdf', size: 100, type: 'application/pdf'});
    assert.strictEqual(alerts.length, 2);
    assert.strictEqual(input.value, '');
    assert.strictEqual(preview.hidden, !oldImage);
}
fixture('/anh-danh-muc?ten=old.png');
fixture(null);
console.log('PASS: product image picker, preview, clear/restore, size and type checks.');

function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    if (sidebar) {
        sidebar.classList.toggle('open');
    }
}

function toggleSubmenu(btn) {
    const group = btn.closest('.nav-group');
    if (!group) return;
    group.classList.toggle('open');
}

function initMenuActive() {
    const links = document.querySelectorAll('.sidebar-menu a.nav-item, .sidebar-menu a.nav-subitem');
    links.forEach((link) => {
        link.addEventListener('click', () => {
            links.forEach((l) => l.classList.remove('active'));
            link.classList.add('active');
        });
    });
}

document.addEventListener('DOMContentLoaded', initMenuActive);

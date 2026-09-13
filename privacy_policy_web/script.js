// Theme toggling with local storage persistence
(function () {
  const themeToggleBtn = document.getElementById('theme-toggle');
  const themeIcon = themeToggleBtn ? themeToggleBtn.querySelector('.theme-icon') : null;
  const rootHtml = document.documentElement;

  // Retrieve saved preference or default to dark
  const savedTheme = localStorage.getItem('picstools_theme') || 'dark';
  setTheme(savedTheme);

  function setTheme(theme) {
    rootHtml.setAttribute('data-theme', theme);
    localStorage.setItem('picstools_theme', theme);
    if (themeIcon) {
      themeIcon.textContent = theme === 'dark' ? '☀️' : '🌙';
    }
  }

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const currentTheme = rootHtml.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      setTheme(newTheme);
    });
  }

  // Smooth active TOC link highlight on scroll
  const sections = document.querySelectorAll('article.policy-section, section#hero');
  const navLinks = document.querySelectorAll('.toc-list a');

  window.addEventListener('scroll', () => {
    let currentId = '';
    const scrollPos = window.scrollY + 120;

    sections.forEach((section) => {
      const top = section.offsetTop;
      const height = section.offsetHeight;
      if (scrollPos >= top && scrollPos < top + height) {
        currentId = section.getAttribute('id');
      }
    });

    navLinks.forEach((link) => {
      const href = link.getAttribute('href').replace('#', '');
      if (href === currentId) {
        link.style.backgroundColor = 'var(--neo-yellow)';
        link.style.color = '#0F172A';
      } else {
        link.style.backgroundColor = '';
        link.style.color = '';
      }
    });
  });
})();

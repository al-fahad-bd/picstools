// ==========================================================================
// PicsTools Web Interactive Engine
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initCategoryFilters();
  initFaqAccordion();
});

// 1. Theme Toggling with LocalStorage Persistence
function initTheme() {
  const themeToggleBtn = document.getElementById('theme-toggle');
  const themeIcon = themeToggleBtn ? themeToggleBtn.querySelector('.theme-icon') : null;
  const rootHtml = document.documentElement;

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
}

// 2. Real App Category Filters (ALL, POPULAR, EDIT, CONVERT, UTILITIES)
function initCategoryFilters() {
  const filterButtons = document.querySelectorAll('.web-cat-btn');
  const toolCards = document.querySelectorAll('.tool-card');
  const phoneCatChips = document.querySelectorAll('.app-cat-chip');
  const phoneToolCards = document.querySelectorAll('.app-tool-mini-card');

  function applyCategory(category) {
    const targetCat = category.toUpperCase();

    // Update Web Buttons
    filterButtons.forEach((btn) => {
      if (btn.getAttribute('data-category').toUpperCase() === targetCat) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });

    // Update Phone Mockup Chips
    phoneCatChips.forEach((chip) => {
      if (chip.getAttribute('data-category').toUpperCase() === targetCat) {
        chip.classList.add('active');
      } else {
        chip.classList.remove('active');
      }
    });

    // Filter Web Tool Cards
    toolCards.forEach((card) => {
      const cardCat = card.getAttribute('data-category').toUpperCase();
      if (targetCat === 'ALL' || cardCat.includes(targetCat)) {
        card.classList.remove('hidden');
      } else {
        card.classList.add('hidden');
      }
    });

    // Filter Phone Mini Cards
    phoneToolCards.forEach((miniCard) => {
      const miniCat = miniCard.getAttribute('data-category').toUpperCase();
      if (targetCat === 'ALL' || miniCat.includes(targetCat)) {
        miniCard.style.display = 'flex';
      } else {
        miniCard.style.display = 'none';
      }
    });
  }

  filterButtons.forEach((btn) => {
    btn.addEventListener('click', () => {
      const category = btn.getAttribute('data-category');
      applyCategory(category);
    });
  });

  phoneCatChips.forEach((chip) => {
    chip.addEventListener('click', () => {
      const category = chip.getAttribute('data-category');
      applyCategory(category);
    });
  });
}

// 3. Interactive FAQ Accordion
function initFaqAccordion() {
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach((item) => {
    const questionBtn = item.querySelector('.faq-question');
    const answerPanel = item.querySelector('.faq-answer');

    if (!questionBtn || !answerPanel) return;

    questionBtn.addEventListener('click', () => {
      const isOpen = item.classList.contains('open');

      faqItems.forEach((other) => {
        other.classList.remove('open');
        const otherAnswer = other.querySelector('.faq-answer');
        if (otherAnswer) otherAnswer.style.maxHeight = null;
      });

      if (!isOpen) {
        item.classList.add('open');
        answerPanel.style.maxHeight = answerPanel.scrollHeight + 30 + 'px';
      } else {
        item.classList.remove('open');
        answerPanel.style.maxHeight = null;
      }
    });
  });
}

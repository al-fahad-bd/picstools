// ==========================================================================
// PicsTools Web Interactive Engine
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initCategoryFilters();
  initFaqAccordion();
  initScrollReveal();
  initStatsCounter();
  initCompressorPlayground();
  initCutoutInteractiveScan();
  initParallaxEffects();
  initCursorGlow();
  initAmbientAudio();
  initCard3DTilt();
  initClientReviewDeck();
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

// 4. Scroll Reveal Motion Engine (IntersectionObserver)
function initScrollReveal() {
  const revealElements = document.querySelectorAll('.reveal');

  if (!('IntersectionObserver' in window)) {
    revealElements.forEach((el) => el.classList.add('is-revealed'));
    return;
  }

  const revealObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-revealed');
        observer.unobserve(entry.target);
      }
    });
  }, {
    root: null,
    threshold: 0.12,
    rootMargin: '0px 0px -40px 0px'
  });

  revealElements.forEach((el) => revealObserver.observe(el));
}

// 5. Dynamic Stats Counter Animation
function initStatsCounter() {
  const statsSection = document.querySelector('.stats-ribbon-section');
  if (!statsSection) return;

  const statCards = statsSection.querySelectorAll('.stat-item-card');
  let animated = false;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting && !animated) {
        animated = true;
        animateCounters();
      }
    });
  }, { threshold: 0.25 });

  observer.observe(statsSection);

  function animateCounters() {
    statCards.forEach((card) => {
      const numElem = card.querySelector('.stat-big-number');
      if (!numElem) return;

      const rawText = numElem.textContent.trim();
      if (rawText.includes('%')) {
        const target = parseInt(rawText);
        runCountUp(numElem, 0, target, '%', 1600);
      } else if (rawText.includes('Tools')) {
        const target = parseInt(rawText);
        runCountUp(numElem, 0, target, ' Tools', 1400);
      } else if (rawText.includes('KB')) {
        numElem.textContent = '0 KB';
      }
    });
  }

  function runCountUp(element, start, end, suffix, duration) {
    const startTime = performance.now();

    function update(currentTime) {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      // Ease out expo
      const ease = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
      const currentVal = Math.round(start + (end - start) * ease);

      element.textContent = currentVal + suffix;

      if (progress < 1) {
        requestAnimationFrame(update);
      }
    }

    requestAnimationFrame(update);
  }
}

// 6. Interactive Lossless Compressor Playground
function initCompressorPlayground() {
  const slider = document.getElementById('compressor-slider');
  const targetVal = document.getElementById('compressor-target-val');
  const compressedSize = document.getElementById('compressed-size-val');
  const savedPercent = document.getElementById('saved-percent-val');

  if (!slider || !targetVal || !compressedSize || !savedPercent) return;

  const originalSizeMB = 8.4; // 8,400 KB

  function updateValues() {
    const percent = parseInt(slider.value);
    targetVal.textContent = percent + '%';

    const remainingRatio = (100 - percent) / 100;
    const finalSizeKB = Math.round(originalSizeMB * 1024 * remainingRatio);

    if (finalSizeKB >= 1024) {
      compressedSize.textContent = (finalSizeKB / 1024).toFixed(1) + ' MB';
    } else {
      compressedSize.textContent = finalSizeKB + ' KB';
    }

    savedPercent.textContent = percent + '%';
  }

  slider.addEventListener('input', updateValues);
  updateValues();
}

// 7. Interactive Cutout Laser Scanner Hover & Touch (Full Edge-to-Edge Sweep)
function initCutoutInteractiveScan() {
  const frame = document.querySelector('.cutout-interactive-frame');
  const laser = document.querySelector('.cutout-laser-beam');
  if (!frame || !laser) return;

  function updateLaserPosition(clientX) {
    const rect = frame.getBoundingClientRect();
    const x = clientX - rect.left;
    const pct = Math.max(1, Math.min(99, (x / rect.width) * 100));
    laser.style.animation = 'none';
    laser.style.left = `${pct}%`;
  }

  frame.addEventListener('mousemove', (e) => {
    updateLaserPosition(e.clientX);
  });

  frame.addEventListener('mouseleave', () => {
    laser.style.animation = 'laserScanAuto 6.5s ease-in-out infinite alternate';
  });

  frame.addEventListener('touchmove', (e) => {
    if (e.touches.length > 0) {
      updateLaserPosition(e.touches[0].clientX);
    }
  }, { passive: true });

  frame.addEventListener('touchend', () => {
    laser.style.animation = 'laserScanAuto 6.5s ease-in-out infinite alternate';
  });
}

// 8. Subtle Parallax Physics for Hero Device & Creator Badge
function initParallaxEffects() {
  const heroWrapper = document.querySelector('.landing-hero');
  const phoneMockup = document.querySelector('.phone-mockup');
  const creatorCard = document.querySelector('.floating-creator-card');

  if (!heroWrapper || !phoneMockup) return;

  heroWrapper.addEventListener('mousemove', (e) => {
    const rect = heroWrapper.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;

    phoneMockup.style.transform = `perspective(1000px) rotateY(${x * 6}deg) rotateX(${-y * 6}deg)`;
    if (creatorCard) {
      creatorCard.style.transform = `translate(${x * 14}px, ${y * 14}px)`;
    }
  });

  heroWrapper.addEventListener('mouseleave', () => {
    phoneMockup.style.transform = 'perspective(1000px) rotateY(0deg) rotateX(0deg)';
    if (creatorCard) {
      creatorCard.style.transform = 'translate(0px, 0px)';
    }
  });
}

// 9. Fluid Ambient Mouse Glow Spotlight
function initCursorGlow() {
  const glow = document.querySelector('.cursor-glow');
  if (!glow) return;

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;
  let currentX = mouseX;
  let currentY = mouseY;

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
    glow.style.opacity = '1';
  });

  window.addEventListener('mouseleave', () => {
    glow.style.opacity = '0';
  });

  function renderGlow() {
    currentX += (mouseX - currentX) * 0.12;
    currentY += (mouseY - currentY) * 0.12;
    glow.style.transform = `translate3d(${currentX - 270}px, ${currentY - 270}px, 0)`;
    requestAnimationFrame(renderGlow);
  }

  renderGlow();
}

// 10. Ambient Lo-Fi / Focus Sound Controller
function initAmbientAudio() {
  const audioBtn = document.getElementById('ambient-audio-toggle');
  if (!audioBtn) return;

  let audio = null;
  let isPlaying = false;

  audioBtn.addEventListener('click', () => {
    if (!audio) {
      audio = new Audio('assets/cosmic_glow.mp3');
      audio.loop = true;
      audio.volume = 0.45;
    }

    if (!isPlaying) {
      audio.play().then(() => {
        isPlaying = true;
        audioBtn.classList.add('playing');
        audioBtn.querySelector('.audio-label').textContent = 'Focus Sound ON';
      }).catch((e) => {
        console.warn('Audio playback error:', e);
      });
    } else {
      audio.pause();
      isPlaying = false;
      audioBtn.classList.remove('playing');
      audioBtn.querySelector('.audio-label').textContent = 'Ambient Focus';
    }
  });
}

// 11. 3D Card Gyroscope / Tilt Engine on Hover
function initCard3DTilt() {
  const tiltCards = document.querySelectorAll('.neo-card, .biometric-hud-card, .workflow-img-card');

  tiltCards.forEach((card) => {
    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;
      const rotateX = ((y - centerY) / centerY) * -5;
      const rotateY = ((x - centerX) / centerX) * 5;

      card.style.transform = `perspective(800px) rotateX(${rotateX.toFixed(2)}deg) rotateY(${rotateY.toFixed(2)}deg) translateY(-4px)`;
    });

    card.addEventListener('mouseleave', () => {
      card.style.transform = '';
    });
  });
}

// 12. Interactive 3D Stacked Review Deck & Marquee Jump Engine
function initClientReviewDeck() {
  const deckContainer = document.getElementById('review-cards-deck');
  if (!deckContainer) return;

  const cards = Array.from(deckContainer.querySelectorAll('.review-stack-card'));
  if (cards.length === 0) return;

  const counter = document.getElementById('deck-counter');
  const prevBtn = document.getElementById('deck-prev-btn');
  const nextBtn = document.getElementById('deck-next-btn');
  const tickerPills = document.querySelectorAll('.client-pill');

  let isAnimating = false;
  let activeCards = [...cards];
  let discardDirectionAlternator = 'right';

  function updateSlots() {
    activeCards.forEach((card, idx) => {
      card.setAttribute('data-slot', idx);
      card.classList.remove('discard-right', 'discard-left');
    });

    if (counter && activeCards[0]) {
      const realIndex = parseInt(activeCards[0].getAttribute('data-index'), 10) + 1;
      counter.textContent = `${realIndex} / ${cards.length}`;
    }
  }

  function cycleNext(direction = null) {
    if (isAnimating || activeCards.length <= 1) return;
    isAnimating = true;

    // Use passed direction (e.g. from swipe), or alternate between right and left
    const chosenDir = direction || discardDirectionAlternator;
    discardDirectionAlternator = chosenDir === 'right' ? 'left' : 'right';

    const topCard = activeCards[0];
    const discardClass = chosenDir === 'left' ? 'discard-left' : 'discard-right';
    topCard.classList.add(discardClass);

    setTimeout(() => {
      topCard.classList.remove(discardClass);
      activeCards.push(activeCards.shift()); // Loop to back of stack infinitely
      updateSlots();
      isAnimating = false;
    }, 320);
  }

  function cyclePrev() {
    if (isAnimating || activeCards.length <= 1) return;
    isAnimating = true;

    const lastCard = activeCards.pop();
    activeCards.unshift(lastCard);
    updateSlots();

    setTimeout(() => {
      isAnimating = false;
    }, 280);
  }

  // Advance on clicking anywhere on the top card (alternates right and left)
  deckContainer.addEventListener('click', (e) => {
    const clickedCard = e.target.closest('.review-stack-card');
    if (clickedCard && clickedCard.getAttribute('data-slot') === '0') {
      cycleNext();
    }
  });

  // Mobile Touch Swipe Gestures
  let touchStartX = 0;
  let touchStartY = 0;
  let isSwiping = false;

  deckContainer.addEventListener('touchstart', (e) => {
    if (e.touches.length === 1) {
      touchStartX = e.touches[0].clientX;
      touchStartY = e.touches[0].clientY;
      isSwiping = true;
    }
  }, { passive: true });

  deckContainer.addEventListener('touchend', (e) => {
    if (!isSwiping || e.changedTouches.length === 0) return;
    isSwiping = false;
    const touchEndX = e.changedTouches[0].clientX;
    const touchEndY = e.changedTouches[0].clientY;
    const diffX = touchEndX - touchStartX;
    const diffY = touchEndY - touchStartY;

    if (Math.abs(diffX) > 40 && Math.abs(diffX) > Math.abs(diffY)) {
      if (diffX < 0) {
        cycleNext('left');
      } else {
        cycleNext('right');
      }
    }
  }, { passive: true });

  // Navigation Buttons
  if (nextBtn) {
    nextBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      cycleNext(); // Alternates direction (one right, next left)
    });
  }

  if (prevBtn) {
    prevBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      cyclePrev();
    });
  }

  // Keyboard accessibility: Left / Right arrow navigation when deck is focused
  deckContainer.setAttribute('tabindex', '0');
  deckContainer.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight' || e.key === ' ') {
      e.preventDefault();
      cycleNext();
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      cyclePrev();
    }
  });

  // Marquee Pill Clicks to Jump Directly to Specified Card
  tickerPills.forEach((pill) => {
    pill.addEventListener('click', (e) => {
      e.preventDefault();
      const targetIndex = pill.getAttribute('data-card-target');
      if (targetIndex === null || isAnimating) return;

      const targetIdxNum = parseInt(targetIndex, 10);
      let attempts = 0;
      while (parseInt(activeCards[0].getAttribute('data-index'), 10) !== targetIdxNum && attempts < cards.length) {
        activeCards.push(activeCards.shift());
        attempts++;
      }
      updateSlots();

      // Smooth scroll deck into view if needed
      const deckRect = deckContainer.getBoundingClientRect();
      if (deckRect.top < 80 || deckRect.bottom > window.innerHeight) {
        deckContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    });
  });

  // Initialize Slots on Load
  updateSlots();
}

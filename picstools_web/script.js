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
  initToolsStudio();
  initMobileNavigation();
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
  const toolTabs = document.querySelectorAll('.studio-tool-tab');
  const phoneCatChips = document.querySelectorAll('.app-cat-chip');
  const phoneToolCards = document.querySelectorAll('.app-tool-mini-card');

  function applyCategory(category) {
    const targetCat = category.toUpperCase();

    // Update Web Category Buttons
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

    // Filter Studio Tool Tabs
    let firstVisibleTab = null;
    toolTabs.forEach((tab) => {
      const tabCat = (tab.getAttribute('data-category') || '').toUpperCase();
      if (targetCat === 'ALL' || tabCat.includes(targetCat)) {
        tab.classList.remove('hidden');
        if (!firstVisibleTab) firstVisibleTab = tab;
      } else {
        tab.classList.add('hidden');
      }
    });

    // If the currently active tool tab was filtered out, switch to first visible
    const activeTab = document.querySelector('.studio-tool-tab.active');
    if (activeTab && activeTab.classList.contains('hidden') && firstVisibleTab) {
      if (window.switchStudioTool) {
        window.switchStudioTool(firstVisibleTab.getAttribute('data-tool'));
      } else {
        firstVisibleTab.click();
      }
    }

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
    if (window.innerWidth <= 768) return;
    const rect = heroWrapper.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;

    phoneMockup.style.transform = `perspective(1000px) rotateY(${x * 6}deg) rotateX(${-y * 6}deg)`;
    if (creatorCard) {
      creatorCard.style.transform = `translate(${x * 14}px, ${y * 14}px)`;
    }
  });

  heroWrapper.addEventListener('mouseleave', () => {
    if (window.innerWidth <= 768) return;
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
  const sidebarAudioBtn = document.getElementById('sidebar-ambient-toggle');
  const sidebarAudioBadge = document.getElementById('sidebar-audio-badge');
  if (!audioBtn && !sidebarAudioBtn) return;

  let audio = null;
  let isPlaying = false;

  function updateAudioUI(playing) {
    isPlaying = playing;
    if (audioBtn) {
      if (playing) {
        audioBtn.classList.add('playing');
        const label = audioBtn.querySelector('.audio-label');
        if (label) label.textContent = 'Focus Sound ON';
      } else {
        audioBtn.classList.remove('playing');
        const label = audioBtn.querySelector('.audio-label');
        if (label) label.textContent = 'Ambient Focus';
      }
    }
    if (sidebarAudioBtn) {
      if (playing) {
        sidebarAudioBtn.classList.add('playing');
      } else {
        sidebarAudioBtn.classList.remove('playing');
      }
    }
    if (sidebarAudioBadge) {
      sidebarAudioBadge.textContent = playing ? 'ON' : 'OFF';
      sidebarAudioBadge.classList.toggle('active', playing);
    }
  }

  function toggleAudio() {
    if (!audio) {
      audio = new Audio('assets/cosmic_glow.mp3');
      audio.loop = true;
      audio.volume = 0.45;
    }

    if (!isPlaying) {
      audio.play().then(() => {
        updateAudioUI(true);
      }).catch((e) => {
        console.warn('Audio playback error:', e);
      });
    } else {
      audio.pause();
      updateAudioUI(false);
    }
  }

  if (audioBtn) {
    audioBtn.addEventListener('click', toggleAudio);
  }
  if (sidebarAudioBtn) {
    sidebarAudioBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      toggleAudio();
    });
  }
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

// ==========================================================================
// 13. Interactive 8 Tools Studio Workbench & Micro-Playgrounds
// ==========================================================================
function initToolsStudio() {
  const toolTabs = Array.from(document.querySelectorAll('.studio-tool-tab'));
  const stagePanels = Array.from(document.querySelectorAll('.stage-panel'));
  const stageDots = Array.from(document.querySelectorAll('.stage-dot'));
  const activeCounter = document.getElementById('studio-active-num');
  const prevBtn = document.getElementById('stage-prev-btn');
  const nextBtn = document.getElementById('stage-next-btn');
  const tourBtn = document.getElementById('studio-tour-btn');
  const stageContainer = document.getElementById('studio-stage-container');

  if (!toolTabs.length || !stagePanels.length) return;

  let currentIndex = 0;
  let isTouring = false;
  let tourTimer = null;

  // Switch to specific tool
  function switchTool(target, isManual = true) {
    let targetIndex = -1;

    if (typeof target === 'number') {
      targetIndex = target;
    } else if (typeof target === 'string') {
      targetIndex = toolTabs.findIndex((tab) => tab.getAttribute('data-tool') === target);
    }

    if (targetIndex < 0 || targetIndex >= toolTabs.length) return;

    currentIndex = targetIndex;
    const activeTab = toolTabs[currentIndex];
    const toolName = activeTab.getAttribute('data-tool');

    // 1. Update Tabs
    toolTabs.forEach((tab, idx) => {
      if (idx === currentIndex) {
        tab.classList.add('active');
        tab.setAttribute('aria-selected', 'true');
        // Smoothly bring tab into view inside horizontal tabs bar on mobile
        const tabsContainer = tab.closest('.studio-tool-tabs');
        if (tabsContainer) {
          const scrollLeft = tab.offsetLeft - tabsContainer.offsetLeft - 12;
          tabsContainer.scrollTo({ left: Math.max(0, scrollLeft), behavior: 'smooth' });
        }
      } else {
        tab.classList.remove('active');
        tab.setAttribute('aria-selected', 'false');
      }
    });

    // 2. Update Stage Panels
    stagePanels.forEach((panel) => {
      if (panel.getAttribute('data-tool') === toolName) {
        panel.classList.add('active');
      } else {
        panel.classList.remove('active');
      }
    });

    // 3. Update Dots & Counter
    stageDots.forEach((dot, idx) => {
      if (idx === currentIndex) {
        dot.classList.add('active');
      } else {
        dot.classList.remove('active');
      }
    });

    if (activeCounter) {
      activeCounter.textContent = (currentIndex + 1).toString();
    }

    // Special setup for signature canvas when selected
    if (toolName === 'signature') {
      setupSignatureCanvas();
    }
  }

  // Global handle for category filter to call
  window.switchStudioTool = (toolId) => switchTool(toolId, true);

  // Tab click listeners
  toolTabs.forEach((tab, index) => {
    tab.addEventListener('click', () => {
      switchTool(index, true);
      if (isTouring) stopTour();
    });
  });

  // Dots click listeners
  stageDots.forEach((dot, index) => {
    dot.addEventListener('click', () => {
      switchTool(index, true);
      if (isTouring) stopTour();
    });
  });

  // Next / Previous Engine Controls
  function nextEngine() {
    const visibleTabs = toolTabs.filter((t) => !t.classList.contains('hidden'));
    if (!visibleTabs.length) return;
    const currentTab = toolTabs[currentIndex];
    let visibleIdx = visibleTabs.indexOf(currentTab);
    visibleIdx = (visibleIdx + 1) % visibleTabs.length;
    const nextTab = visibleTabs[visibleIdx];
    switchTool(toolTabs.indexOf(nextTab), false);
  }

  function prevEngine() {
    const visibleTabs = toolTabs.filter((t) => !t.classList.contains('hidden'));
    if (!visibleTabs.length) return;
    const currentTab = toolTabs[currentIndex];
    let visibleIdx = visibleTabs.indexOf(currentTab);
    visibleIdx = (visibleIdx - 1 + visibleTabs.length) % visibleTabs.length;
    const prevTab = visibleTabs[visibleIdx];
    switchTool(toolTabs.indexOf(prevTab), false);
  }

  if (nextBtn) {
    nextBtn.addEventListener('click', () => {
      nextEngine();
      if (isTouring) stopTour();
    });
  }

  if (prevBtn) {
    prevBtn.addEventListener('click', () => {
      prevEngine();
      if (isTouring) stopTour();
    });
  }

  // Auto Tour Controller
  function startTour() {
    isTouring = true;
    if (tourBtn) tourBtn.classList.add('active');
    clearInterval(tourTimer);
    tourTimer = setInterval(() => {
      nextEngine();
    }, 4500);
  }

  function stopTour() {
    isTouring = false;
    if (tourBtn) tourBtn.classList.remove('active');
    clearInterval(tourTimer);
  }

  if (tourBtn) {
    tourBtn.addEventListener('click', () => {
      if (isTouring) {
        stopTour();
      } else {
        startTour();
      }
    });
  }

  // Pause tour on stage hover
  if (stageContainer) {
    stageContainer.addEventListener('mouseenter', () => {
      if (isTouring) clearInterval(tourTimer);
    });
    stageContainer.addEventListener('mouseleave', () => {
      if (isTouring) {
        clearInterval(tourTimer);
        tourTimer = setInterval(nextEngine, 4500);
      }
    });
  }

  // Keyboard Navigation
  stageContainer.setAttribute('tabindex', '0');
  stageContainer.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight') {
      e.preventDefault();
      nextEngine();
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      prevEngine();
    }
  });

  // --------------------------------------------------------------------------
  // Micro-Simulators Logic
  // --------------------------------------------------------------------------

  // 1. Simulator: Compress Image
  const compSlider = document.getElementById('sim-comp-slider');
  const compSliderVal = document.getElementById('sim-comp-slider-val');
  const compOutput = document.getElementById('sim-comp-output');
  const compRatio = document.getElementById('sim-comp-ratio');
  const compAction = document.getElementById('sim-comp-action');

  if (compSlider) {
    compSlider.addEventListener('input', () => {
      const val = parseInt(compSlider.value, 10);
      if (compSliderVal) compSliderVal.textContent = `${val}%`;
      if (compRatio) compRatio.textContent = `-${val}% SHRUNK`;
      if (compOutput) {
        const origMB = 14.2;
        const shrunkMB = (origMB * (1 - val / 100)).toFixed(1);
        compOutput.textContent = `${shrunkMB} MB`;
      }
    });
  }

  if (compAction) {
    compAction.addEventListener('click', () => {
      const originalText = compAction.innerHTML;
      compAction.innerHTML = '<span>✓ Saved to Photos (Lossless)</span>';
      compAction.style.background = 'var(--neo-green)';
      setTimeout(() => {
        compAction.innerHTML = originalText;
        compAction.style.background = '';
      }, 2000);
    });
  }

  // 2. Simulator: Image to PDF
  const pdfPills = document.querySelectorAll('.simulator-pdf .sim-pill-btn');
  const pdfAction = document.getElementById('sim-pdf-action');
  const pdfCards = document.querySelectorAll('.pdf-page-card');

  pdfPills.forEach((pill) => {
    pill.addEventListener('click', () => {
      pdfPills.forEach((p) => p.classList.remove('active'));
      pill.classList.add('active');
    });
  });

  pdfCards.forEach((card) => {
    card.addEventListener('click', () => {
      card.style.transform = 'translateY(-8px) scale(1.05)';
      setTimeout(() => {
        card.style.transform = '';
      }, 300);
    });
  });

  if (pdfAction) {
    pdfAction.addEventListener('click', () => {
      const originalText = pdfAction.innerHTML;
      pdfAction.innerHTML = '<span>✓ Single PDF Generated (412 KB)</span>';
      pdfAction.style.background = 'var(--neo-purple)';
      pdfAction.style.color = '#FFFFFF';
      setTimeout(() => {
        pdfAction.innerHTML = originalText;
        pdfAction.style.background = '';
        pdfAction.style.color = '';
      }, 2000);
    });
  }

  // 3. Simulator: Resize Image
  const resizePills = document.querySelectorAll('#sim-resize-pills .sim-pill-btn');
  const resizePct = document.getElementById('sim-resize-pct');
  const resizeTarget = document.getElementById('sim-resize-target-val');
  const resizeBox = document.getElementById('sim-resize-box');
  const resizeAction = document.getElementById('sim-resize-action');

  resizePills.forEach((pill) => {
    pill.addEventListener('click', () => {
      resizePills.forEach((p) => p.classList.remove('active'));
      pill.classList.add('active');
      const scale = parseFloat(pill.getAttribute('data-scale') || '0.5');
      const w = pill.getAttribute('data-w') || '2016';
      const h = pill.getAttribute('data-h') || '1512';

      if (resizePct) resizePct.textContent = `${Math.round(scale * 100)}% Scale`;
      if (resizeTarget) resizeTarget.textContent = `${w} × ${h} px`;
      const dimLabel = document.getElementById('sim-dimension-label');
      if (dimLabel) dimLabel.textContent = `${w} × ${h} px`;

      if (resizeBox) {
        // Visual scale inside container
        const visualScale = 0.35 + scale * 0.45;
        resizeBox.style.transform = `scale(${visualScale})`;
      }
    });
  });

  if (resizeAction) {
    resizeAction.addEventListener('click', () => {
      const orig = resizeAction.innerHTML;
      resizeAction.innerHTML = '<span>✓ Resized to Exact Dimensions!</span>';
      resizeAction.style.background = 'var(--neo-cyan)';
      setTimeout(() => {
        resizeAction.innerHTML = orig;
        resizeAction.style.background = '';
      }, 2000);
    });
  }

  // 4. Simulator: Crop & Rotate
  const cropPills = document.querySelectorAll('#sim-crop-pills .sim-pill-btn');
  const cropFrame = document.getElementById('sim-crop-frame');
  const cropImg = document.getElementById('sim-crop-img');
  const cropBadge = document.getElementById('sim-crop-aspect-badge');
  const rotateLeftBtn = document.getElementById('sim-rotate-left');
  const rotateRightBtn = document.getElementById('sim-rotate-right');
  const rotateFlipBtn = document.getElementById('sim-rotate-flip');
  const cropAction = document.getElementById('sim-crop-action');

  let currentRotate = 0;
  let isFlipped = false;

  function applyCropTransform() {
    if (!cropImg) return;
    const flipScale = isFlipped ? -1 : 1;
    cropImg.style.transform = `rotate(${currentRotate}deg) scaleX(${flipScale})`;
  }

  if (rotateLeftBtn) {
    rotateLeftBtn.addEventListener('click', () => {
      currentRotate -= 90;
      applyCropTransform();
    });
  }

  if (rotateRightBtn) {
    rotateRightBtn.addEventListener('click', () => {
      currentRotate += 90;
      applyCropTransform();
    });
  }

  if (rotateFlipBtn) {
    rotateFlipBtn.addEventListener('click', () => {
      isFlipped = !isFlipped;
      applyCropTransform();
    });
  }

  cropPills.forEach((pill) => {
    pill.addEventListener('click', () => {
      cropPills.forEach((p) => p.classList.remove('active'));
      pill.classList.add('active');
      const ratio = pill.getAttribute('data-ratio');
      if (cropFrame) {
        cropFrame.className = `sim-crop-frame ratio-${ratio}`;
      }
      if (cropBadge) {
        cropBadge.textContent = pill.textContent.toUpperCase();
      }
    });
  });

  if (cropAction) {
    cropAction.addEventListener('click', () => {
      const orig = cropAction.innerHTML;
      cropAction.innerHTML = '<span>✓ Aspect Ratio Cropped!</span>';
      cropAction.style.background = 'var(--neo-pink)';
      cropAction.style.color = '#FFF';
      setTimeout(() => {
        cropAction.innerHTML = orig;
        cropAction.style.background = '';
        cropAction.style.color = '';
      }, 2000);
    });
  }

  // 5. Simulator: Format Convert
  const convertPills = document.querySelectorAll('#sim-convert-pills .sim-pill-btn');
  const targetExt = document.getElementById('sim-target-ext');
  const targetInfo = document.getElementById('sim-target-info');
  const convertAction = document.getElementById('sim-convert-action');

  convertPills.forEach((pill) => {
    pill.addEventListener('click', () => {
      convertPills.forEach((p) => p.classList.remove('active'));
      pill.classList.add('active');
      const fmt = pill.getAttribute('data-format');
      const info = pill.getAttribute('data-info');
      if (targetExt) targetExt.textContent = fmt;
      if (targetInfo) targetInfo.textContent = info;
    });
  });

  if (convertAction) {
    convertAction.addEventListener('click', () => {
      const orig = convertAction.innerHTML;
      convertAction.innerHTML = '<span>⚡ Transcoding on ARM64 NPU...</span>';
      setTimeout(() => {
        convertAction.innerHTML = '<span>✓ Converted in 0.14s (Lossless)</span>';
        convertAction.style.background = 'var(--neo-green)';
        convertAction.style.color = '#FFF';
        setTimeout(() => {
          convertAction.innerHTML = orig;
          convertAction.style.background = '';
          convertAction.style.color = '';
        }, 2200);
      }, 400);
    });
  }

  // 6. Simulator: Passport ID
  const passportPills = document.querySelectorAll('#sim-passport-pills .sim-pill-btn');
  const passportPillBadge = document.getElementById('sim-passport-pill');
  const toggleGuides = document.getElementById('sim-toggle-guides');
  const toggleSheet = document.getElementById('sim-toggle-sheet');
  const biometricGuides = document.getElementById('sim-biometric-guides');
  const passportAction = document.getElementById('sim-passport-action');

  passportPills.forEach((pill) => {
    pill.addEventListener('click', () => {
      passportPills.forEach((p) => p.classList.remove('active'));
      pill.classList.add('active');
      const country = pill.getAttribute('data-country');
      if (passportPillBadge) passportPillBadge.textContent = country.toUpperCase();
    });
  });

  if (toggleGuides && biometricGuides) {
    toggleGuides.addEventListener('click', () => {
      biometricGuides.classList.toggle('hidden');
      const isHidden = biometricGuides.classList.contains('hidden');
      toggleGuides.textContent = isHidden ? 'Guides: OFF' : 'Guides: ON';
      toggleGuides.classList.toggle('active', !isHidden);
    });
  }

  if (toggleSheet) {
    toggleSheet.addEventListener('click', () => {
      toggleSheet.classList.toggle('active');
      const isActive = toggleSheet.classList.contains('active');
      toggleSheet.textContent = isActive ? '6-Photo Sheet: ON' : '6-Photo Sheet: OFF';
    });
  }

  if (passportAction) {
    passportAction.addEventListener('click', () => {
      const orig = passportAction.innerHTML;
      passportAction.innerHTML = '<span>✓ Compliant Biometric ID Exported!</span>';
      passportAction.style.background = 'var(--neo-orange)';
      passportAction.style.color = '#FFF';
      setTimeout(() => {
        passportAction.innerHTML = orig;
        passportAction.style.background = '';
        passportAction.style.color = '';
      }, 2000);
    });
  }

  // 7. Simulator: Digital Signature Canvas
  let canvasInitialized = false;
  let canvas = null;
  let ctx = null;
  let isDrawing = false;
  let strokeColor = '#0F172A';

  function setupSignatureCanvas() {
    canvas = document.getElementById('live-signature-canvas');
    if (!canvas) return;

    ctx = canvas.getContext('2d');
    const watermark = document.getElementById('canvas-watermark');
    const clearBtn = document.getElementById('sig-clear-btn');
    const inkDots = document.querySelectorAll('.ink-dot');
    const sigAction = document.getElementById('sim-sig-action');

    if (!canvasInitialized) {
      canvasInitialized = true;

      // Ensure proper canvas pixel ratio
      function resizeCanvas() {
        const rect = canvas.getBoundingClientRect();
        if (rect.width === 0) return;
        canvas.width = rect.width * 2;
        canvas.height = rect.height * 2;
        ctx.scale(2, 2);
        ctx.lineCap = 'round';
        ctx.lineJoin = 'round';
        ctx.lineWidth = 3;
        ctx.strokeStyle = strokeColor;
      }

      resizeCanvas();
      window.addEventListener('resize', resizeCanvas);

      function getPos(e) {
        const rect = canvas.getBoundingClientRect();
        const clientX = e.touches ? e.touches[0].clientX : e.clientX;
        const clientY = e.touches ? e.touches[0].clientY : e.clientY;
        return {
          x: clientX - rect.left,
          y: clientY - rect.top,
        };
      }

      function startDraw(e) {
        isDrawing = true;
        const pos = getPos(e);
        ctx.beginPath();
        ctx.moveTo(pos.x, pos.y);
        if (watermark) watermark.style.opacity = '0';
      }

      function draw(e) {
        if (!isDrawing) return;
        e.preventDefault();
        const pos = getPos(e);
        ctx.lineTo(pos.x, pos.y);
        ctx.stroke();
      }

      function stopDraw() {
        isDrawing = false;
      }

      canvas.addEventListener('mousedown', startDraw);
      canvas.addEventListener('mousemove', draw);
      canvas.addEventListener('mouseup', stopDraw);
      canvas.addEventListener('mouseleave', stopDraw);

      canvas.addEventListener('touchstart', startDraw, { passive: false });
      canvas.addEventListener('touchmove', draw, { passive: false });
      canvas.addEventListener('touchend', stopDraw);

      if (clearBtn) {
        clearBtn.addEventListener('click', () => {
          ctx.clearRect(0, 0, canvas.width, canvas.height);
          if (watermark) watermark.style.opacity = '1';
        });
      }

      inkDots.forEach((dot) => {
        dot.addEventListener('click', () => {
          inkDots.forEach((d) => d.classList.remove('active'));
          dot.classList.add('active');
          strokeColor = dot.getAttribute('data-color') || '#0F172A';
          ctx.strokeStyle = strokeColor;
        });
      });

      if (sigAction) {
        sigAction.addEventListener('click', () => {
          const orig = sigAction.innerHTML;
          sigAction.innerHTML = '<span>✓ Exported Transparent PNG!</span>';
          sigAction.style.background = 'var(--neo-blue)';
          sigAction.style.color = '#FFF';
          setTimeout(() => {
            sigAction.innerHTML = orig;
            sigAction.style.background = '';
            sigAction.style.color = '';
          }, 2000);
        });
      }
    }
  }

  // 8. Simulator: Remove Background Split Slider
  const cutoutContainer = document.getElementById('sim-cutout-compare');
  const cutoutBefore = document.getElementById('cutout-before-clip');
  const cutoutHandle = document.getElementById('cutout-slider-handle');
  const cutoutAction = document.getElementById('sim-cutout-action');

  if (cutoutContainer && cutoutBefore && cutoutHandle) {
    let isDraggingSlider = false;

    function updateCutoutSplit(clientX) {
      const rect = cutoutContainer.getBoundingClientRect();
      let pos = (clientX - rect.left) / rect.width;
      pos = Math.max(0.05, Math.min(0.95, pos));
      const pct = (pos * 100).toFixed(2);
      cutoutBefore.style.width = `${pct}%`;
      cutoutHandle.style.left = `${pct}%`;
    }

    cutoutContainer.addEventListener('mousedown', (e) => {
      isDraggingSlider = true;
      updateCutoutSplit(e.clientX);
    });

    window.addEventListener('mousemove', (e) => {
      if (!isDraggingSlider) return;
      updateCutoutSplit(e.clientX);
    });

    window.addEventListener('mouseup', () => {
      isDraggingSlider = false;
    });

    cutoutContainer.addEventListener('touchstart', (e) => {
      isDraggingSlider = true;
      if (e.touches && e.touches[0]) updateCutoutSplit(e.touches[0].clientX);
    }, { passive: true });

    window.addEventListener('touchmove', (e) => {
      if (!isDraggingSlider) return;
      if (e.touches && e.touches[0]) updateCutoutSplit(e.touches[0].clientX);
    }, { passive: true });

    window.addEventListener('touchend', () => {
      isDraggingSlider = false;
    });
  }

  if (cutoutAction) {
    cutoutAction.addEventListener('click', () => {
      const orig = cutoutAction.innerHTML;
      cutoutAction.innerHTML = '<span>✓ Saved Transparent PNG!</span>';
      cutoutAction.style.background = 'var(--neo-purple)';
      cutoutAction.style.color = '#FFF';
      setTimeout(() => {
        cutoutAction.innerHTML = orig;
        cutoutAction.style.background = '';
        cutoutAction.style.color = '';
      }, 2000);
    });
  }
}

// Mobile Sidebar Navigation & Drawer Controller
function initMobileNavigation() {
  const menuToggle = document.getElementById('mobile-menu-toggle');
  const menuClose = document.getElementById('mobile-menu-close');
  const sidebar = document.getElementById('mobile-sidebar');
  const backdrop = document.getElementById('mobile-sidebar-backdrop');
  if (!sidebar) return;

  function openSidebar() {
    sidebar.classList.add('open');
    if (backdrop) backdrop.classList.add('open');
    if (menuToggle) {
      menuToggle.classList.add('active');
      menuToggle.setAttribute('aria-expanded', 'true');
    }
    sidebar.setAttribute('aria-hidden', 'false');
    document.body.classList.add('mobile-nav-locked');
  }

  function closeSidebar() {
    sidebar.classList.remove('open');
    if (backdrop) backdrop.classList.remove('open');
    if (menuToggle) {
      menuToggle.classList.remove('active');
      menuToggle.setAttribute('aria-expanded', 'false');
    }
    sidebar.setAttribute('aria-hidden', 'true');
    document.body.classList.remove('mobile-nav-locked');
  }

  if (menuToggle) {
    menuToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      if (sidebar.classList.contains('open')) {
        closeSidebar();
      } else {
        openSidebar();
      }
    });
  }

  if (menuClose) {
    menuClose.addEventListener('click', (e) => {
      e.stopPropagation();
      closeSidebar();
    });
  }

  if (backdrop) {
    backdrop.addEventListener('click', closeSidebar);
  }

  // Close on Escape key press
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && sidebar.classList.contains('open')) {
      closeSidebar();
    }
  });

  // Close when clicking any link inside the sidebar
  const sidebarLinks = sidebar.querySelectorAll('a');
  sidebarLinks.forEach((link) => {
    link.addEventListener('click', (e) => {
      const href = link.getAttribute('href');
      // If navigating to an anchor on current page
      if (href && href.startsWith('#')) {
        e.preventDefault();
        closeSidebar();
        const targetEl = document.querySelector(href);
        if (targetEl) {
          setTimeout(() => {
            const headerOffset = 80;
            const elementPosition = targetEl.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
            window.scrollTo({
              top: offsetPosition,
              behavior: 'smooth'
            });
          }, 150);
        }
      } else {
        closeSidebar();
      }
    });
  });

  // Automatically close sidebar if screen resized past mobile breakpoint (> 900px)
  window.addEventListener('resize', () => {
    if (window.innerWidth > 900 && sidebar.classList.contains('open')) {
      closeSidebar();
    }
  });
}



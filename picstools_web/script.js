// ==========================================================================
// PicsTools Web Interactive Engine
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initBeforeAfterSlider();
  initSimulatorTabs();
  initCompressorWidget();
  initSignatureWidget();
  initLofiAudio();
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

// 2. Interactive Before / After Image Split Slider
function initBeforeAfterSlider() {
  const container = document.querySelector('.slider-container');
  const beforeWrap = document.querySelector('.slider-img-before-wrap');
  const handle = document.querySelector('.slider-handle');

  if (!container || !beforeWrap || !handle) return;

  let isDragging = false;

  function updateSlider(clientX) {
    const rect = container.getBoundingClientRect();
    let x = clientX - rect.left;
    if (x < 0) x = 0;
    if (x > rect.width) x = rect.width;

    const percent = (x / rect.width) * 100;
    beforeWrap.style.width = `${percent}%`;
    handle.style.left = `${percent}%`;
  }

  container.addEventListener('mousedown', (e) => {
    isDragging = true;
    updateSlider(e.clientX);
  });

  window.addEventListener('mousemove', (e) => {
    if (!isDragging) return;
    updateSlider(e.clientX);
  });

  window.addEventListener('mouseup', () => {
    isDragging = false;
  });

  // Touch Support for mobile devices
  container.addEventListener('touchstart', (e) => {
    isDragging = true;
    if (e.touches.length > 0) {
      updateSlider(e.touches[0].clientX);
    }
  }, { passive: true });

  window.addEventListener('touchmove', (e) => {
    if (!isDragging) return;
    if (e.touches.length > 0) {
      updateSlider(e.touches[0].clientX);
    }
  }, { passive: true });

  window.addEventListener('touchend', () => {
    isDragging = false;
  });
}

// 3. Simulator Switcher Tabs (Inside Phone Screen)
function initSimulatorTabs() {
  const tabs = document.querySelectorAll('.sim-tab');
  const panels = document.querySelectorAll('.sim-panel');

  if (!tabs.length || !panels.length) return;

  tabs.forEach((tab) => {
    tab.addEventListener('click', () => {
      const targetPanelId = tab.getAttribute('data-panel');

      tabs.forEach((t) => t.classList.remove('active'));
      panels.forEach((p) => p.classList.remove('active'));

      tab.classList.add('active');
      const targetPanel = document.getElementById(targetPanelId);
      if (targetPanel) {
        targetPanel.classList.add('active');
      }
    });
  });
}

// 4. Interactive Lossless Compressor Simulator
function initCompressorWidget() {
  const slider = document.getElementById('comp-target-slider');
  const sizeOutput = document.getElementById('comp-output-size');
  const pctOutput = document.getElementById('comp-savings-pct');
  const fillBar = document.getElementById('comp-savings-fill');

  if (!slider || !sizeOutput || !pctOutput || !fillBar) return;

  const originalSizeKB = 5400; // 5.4 MB

  slider.addEventListener('input', (e) => {
    const targetKB = parseInt(e.target.value, 10);
    const savingsPct = Math.round(((originalSizeKB - targetKB) / originalSizeKB) * 100);

    let displaySize = '';
    if (targetKB >= 1000) {
      displaySize = (targetKB / 1024).toFixed(1) + ' MB';
    } else {
      displaySize = targetKB + ' KB';
    }

    sizeOutput.textContent = displaySize;
    pctOutput.textContent = `-${savingsPct}% Saved`;
    fillBar.style.width = `${savingsPct}%`;
  });
}

// 5. Signature Scanner Color Swatches
function initSignatureWidget() {
  const swatches = document.querySelectorAll('.sig-color-btn');
  const sigSvg = document.getElementById('signature-path');

  if (!swatches.length || !sigSvg) return;

  swatches.forEach((btn) => {
    btn.addEventListener('click', () => {
      swatches.forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');

      const color = btn.getAttribute('data-color');
      sigSvg.setAttribute('stroke', color);
    });
  });
}

// 6. Relaxing Lo-Fi Ambient Synthesizer & Visualizer
function initLofiAudio() {
  const toggleBtn = document.getElementById('btn-lofi-toggle');
  const eqBars = document.querySelectorAll('.eq-bar');
  const statusLabel = document.getElementById('lofi-status-text');

  if (!toggleBtn || !eqBars.length) return;

  let isPlaying = false;
  let audioCtx = null;
  let osc1 = null;
  let osc2 = null;
  let gainNode = null;

  function startAmbientAudio() {
    try {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (!AudioContext) return;

      audioCtx = new AudioContext();

      // Soft dual warm oscillators (C3 chord ambience)
      osc1 = audioCtx.createOscillator();
      osc2 = audioCtx.createOscillator();
      gainNode = audioCtx.createGain();

      const filter = audioCtx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(320, audioCtx.currentTime);

      osc1.type = 'sine';
      osc1.frequency.setValueAtTime(130.81, audioCtx.currentTime); // C3

      osc2.type = 'triangle';
      osc2.frequency.setValueAtTime(196.00, audioCtx.currentTime); // G3

      // Gentle low volume
      gainNode.gain.setValueAtTime(0.06, audioCtx.currentTime);

      osc1.connect(filter);
      osc2.connect(filter);
      filter.connect(gainNode);
      gainNode.connect(audioCtx.destination);

      osc1.start();
      osc2.start();
    } catch (err) {
      console.log('AudioContext initialized without autoplay permissions', err);
    }
  }

  function stopAmbientAudio() {
    if (gainNode && audioCtx) {
      try {
        gainNode.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + 0.5);
        setTimeout(() => {
          if (osc1) osc1.stop();
          if (osc2) osc2.stop();
          if (audioCtx) audioCtx.close();
        }, 500);
      } catch (e) {}
    }
  }

  toggleBtn.addEventListener('click', () => {
    isPlaying = !isPlaying;

    if (isPlaying) {
      eqBars.forEach((bar) => bar.classList.add('playing'));
      toggleBtn.innerHTML = '<span>⏸ Pause Chill Beat</span>';
      if (statusLabel) statusLabel.textContent = 'Playing: 🎵 Lo-Fi Rain & Chill Chords (Looping)';
      startAmbientAudio();
    } else {
      eqBars.forEach((bar) => bar.classList.remove('playing'));
      toggleBtn.innerHTML = '<span>▶ Play Ambient Beat</span>';
      if (statusLabel) statusLabel.textContent = 'Audio Paused (Click to preview in-app Lo-Fi)';
      stopAmbientAudio();
    }
  });
}

// 7. Interactive FAQ Accordion
function initFaqAccordion() {
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach((item) => {
    const questionBtn = item.querySelector('.faq-question');
    const answerPanel = item.querySelector('.faq-answer');

    if (!questionBtn || !answerPanel) return;

    questionBtn.addEventListener('click', () => {
      const isOpen = item.classList.contains('open');

      // Close all other items for clean single-focus accordion
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

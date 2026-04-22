// Utility helpers for building DayDone slides
window.DD = (function() {
  const h = (tag, attrs = {}, children = []) => {
    const el = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs)) {
      if (k === 'class') el.className = v;
      else if (k === 'style') el.setAttribute('style', v);
      else if (k === 'html') el.innerHTML = v;
      else el.setAttribute(k, v);
    }
    const kids = Array.isArray(children) ? children : [children];
    for (const c of kids) {
      if (c == null || c === false) continue;
      if (typeof c === 'string') el.appendChild(document.createTextNode(c));
      else el.appendChild(c);
    }
    return el;
  };

  // Newer Material Symbols icons (not in classic Material Icons font) → use codepoint
  const SYMBOLS_ONLY = {
    task_alt: '\ue2e6',
    add_task: '\uf23a',
    nightlight: '\uef5f',
    insights: '\uf092',
    filter_alt_off: '\ueb32',
    edit_calendar: '\ue750',
    bolt: '\uea0b',
    battery_alert: '\ue19c',
  };
  const mi = (name, cls = '') => {
    const s = document.createElement('span');
    s.className = 'mi ' + cls;
    if (SYMBOLS_ONLY[name]) {
      s.textContent = SYMBOLS_ONLY[name];
      s.style.fontFamily = "'Material Symbols Outlined'";
    } else {
      s.textContent = name;
    }
    return s;
  };

  // Phone frame
  function phone(mode, screenContent) {
    const p = h('div', { class: 'phone ' + (mode === 'dark' ? 'dark' : ''), style: mode === 'dark' ? '' : '' });
    const sc = h('div', { class: 'screen' });
    const punch = h('div', { class: 'punch' });
    // Status bar
    const sb = h('div', { class: 'status-bar' }, [
      h('span', {}, '9:41'),
      h('div', { class: 'status-right' }, [
        mi('signal_cellular_alt', ''), mi('wifi', ''), mi('battery_full', '')
      ])
    ]);
    const body = h('div', { class: 'app-body' }, screenContent);
    sc.append(punch, sb, body);
    p.append(sc);
    return p;
  }

  // Standard bottom nav (active = today/calendar/backlog/reports/settings)
  function bottomNav(active = 'today') {
    const tabs = [
      { key: 'today', icon: 'today', label: 'Today' },
      { key: 'calendar', icon: 'calendar_month', label: 'Calendar' },
      { key: 'backlog', icon: 'list_alt', label: 'Backlog' },
      { key: 'reports', icon: 'bar_chart', label: 'Reports' },
      { key: 'settings', icon: 'settings', label: 'Settings' },
    ];
    return h('div', { class: 'bottom-nav' }, tabs.map(t => {
      const tab = h('div', { class: 'nav-tab' + (t.key === active ? ' active' : '') }, [
        h('div', { class: 'nav-pill' }, mi(t.icon, t.key === active ? 'filled' : '')),
        h('span', {}, t.label)
      ]);
      return tab;
    }));
  }

  // Task tile
  // opts: { title, priority: 'urgent|high|medium|low|none', status: 'pending|done|closed|snoozed',
  //         chips: [], quant: {done, total, unit, pct}, overdue, snoozedUntil, urgentState }
  function tile(opts) {
    const pcolor = {
      urgent: 'var(--p-urgent)', high: 'var(--p-high)', medium: 'var(--p-medium)',
      low: 'var(--p-low)', none: 'transparent'
    }[opts.priority || 'none'];

    const stripeWidth = opts.priority === 'none' ? '0' : '4px';
    const stripe = h('div', { class: 'stripe', style: `background:${pcolor}; width:${stripeWidth};` });

    let check;
    if (opts.status === 'done') {
      check = h('div', { class: 'checkbox done' }, mi('check', ''));
    } else if (opts.status === 'closed') {
      check = h('div', { class: 'checkbox closed' }, mi('close', ''));
    } else {
      check = h('div', { class: 'checkbox' });
    }

    const titleCls = 'title' + (opts.status === 'done' ? ' strike' : '') + (opts.status === 'closed' ? ' closed' : '');

    const titleRow = h('div', { style: 'display:flex; align-items:flex-start; gap:6px; flex-wrap:wrap;' });
    if (opts.overdue) {
      titleRow.append(h('span', { class: 'chip overdue', style: 'margin-top: 1px;' }, 'From yesterday'));
    }
    titleRow.append(h('span', { class: titleCls }, opts.title));

    const main = h('div', { class: 'main' }, titleRow);

    if (opts.chips && opts.chips.length) {
      const chipsRow = h('div', { class: 'chips' });
      opts.chips.slice(0, 3).forEach(c => chipsRow.append(h('span', { class: 'chip' }, c)));
      if (opts.chips.length > 3) chipsRow.append(h('span', { class: 'chip' }, `+${opts.chips.length - 3}`));
      main.append(chipsRow);
    }

    if (opts.quant) {
      const pct = opts.quant.pct != null ? opts.quant.pct : Math.round((opts.quant.done / opts.quant.total) * 100);
      const color = pct >= 80 ? 'var(--progress-on-track)' : pct > 0 ? 'var(--progress-partial)' : 'transparent';
      main.append(h('div', { class: 'progress-row' }, [
        h('div', { class: 'progress-bar' }, [
          h('div', { class: 'progress-fill', style: `width:${Math.min(pct, 100)}%; background:${color};` })
        ]),
        h('div', { class: 'progress-label' }, `${opts.quant.done} / ${opts.quant.total} ${opts.quant.unit}`)
      ]));
    }

    if (opts.snoozedUntil) {
      main.append(h('div', { class: 'snoozed-line' }, [mi('schedule', ''), `Snoozed until ${opts.snoozedUntil}`]));
    }

    const actions = h('div', { class: 'actions' }, [
      opts.status === 'pending' ? mi('schedule', '') : null,
      mi('more_vert', '')
    ].filter(Boolean));

    const body = h('div', { class: 'body' }, [check, main, actions]);

    let cls = 'tile';
    if (opts.priority === 'urgent') cls += ' urgent';
    if (opts.status === 'snoozed') cls += ' snoozed';
    if (opts.urgentState) cls += ' urgent-state';

    return h('div', { class: cls }, [stripe, body]);
  }

  // Section header with count
  function sectionHeader(label, cls = '') {
    return h('div', { class: 'section-header ' + cls }, label);
  }

  // Filter bar
  function filterBar(chips) {
    const bar = h('div', { class: 'filter-bar' });
    chips.forEach(c => {
      const el = h('span', { class: 'filter-chip' + (c.active ? ' active' : '') }, c.label);
      bar.append(el);
    });
    return bar;
  }

  return { h, mi, phone, bottomNav, tile, sectionHeader, filterBar };
})();

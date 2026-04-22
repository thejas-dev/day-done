// Build all DayDone slides
(function() {
  const { h, mi, phone, bottomNav, tile, sectionHeader, filterBar } = window.DD;

  const sections = document.querySelectorAll('deck-stage > section');

  // Helper: wrap a phone with mode label
  function phoneWrap(mode, screen) {
    return h('div', { class: 'phone-wrap' }, [
      h('span', { class: 'ph-mode ' + (mode === 'light' ? 'light' : '') }, mode === 'light' ? 'Light' : 'Dark'),
      (() => { const p = phone(mode, screen()); if (mode === 'dark') p.classList.add('dark'); return p; })()
    ]);
  }

  // Standard slide shell: eyebrow, title, subtitle, then twin phones + notes
  function slideShell({ eyebrow, title, subtitle, light, dark, notes, stateCaption }) {
    const container = h('div', { class: 'slide-content slide', style: 'background:#0a0a0a; padding: 44px 64px;' });
    const header = h('div', { class: 'slide-header' }, [
      h('div', {}, [
        eyebrow ? h('div', { class: 'slide-eyebrow' }, eyebrow) : null,
        h('h1', { class: 'slide-title' }, title),
        subtitle ? h('p', { class: 'slide-subtitle', style: 'margin-top:12px; margin-bottom:0;' }, subtitle) : null
      ].filter(Boolean)),
    ]);
    container.append(header);

    const body = h('div', { class: 'slide-body', style: 'gap: 56px;' });
    const lightPhone = (() => { const p = phone('light', light()); return h('div', { class: 'phone-wrap' }, [h('span', { class: 'ph-mode light' }, 'Light Mode'), p]); })();
    const darkPhone = (() => { const p = phone('dark', dark()); p.classList.add('dark'); return h('div', { class: 'phone-wrap' }, [h('span', { class: 'ph-mode' }, 'Dark Mode'), p]); })();
    body.append(lightPhone, darkPhone);

    if (notes) {
      const notesBox = h('div', { class: 'notes' }, [
        h('h4', {}, 'Spec notes'),
        h('ul', { html: notes.map(n => `<li>${n}</li>`).join('') })
      ]);
      body.append(notesBox);
    }
    container.append(body);
    return container;
  }

  // ======================================================
  // SLIDE 1: Design system overview (already handled below for sec[1])
  // ======================================================
  function buildDesignSystem() {
    const c = h('div', { class: 'slide-content', style: 'background:#0a0a0a; padding: 56px 80px; display:flex; flex-direction:column; gap:32px; height:100%;' });
    c.append(h('div', {}, [
      h('div', { class: 'slide-eyebrow' }, 'Design foundations'),
      h('h1', { class: 'slide-title' }, 'A system, before a screen.'),
      h('p', { class: 'slide-subtitle', style: 'margin-top:12px;' }, 'DayDone escalates visually as bedtime approaches. Calm by day; urgent by night. Five priority levels, two modes, one tile.')
    ]));

    const row = h('div', { style: 'display:grid; grid-template-columns: 1.2fr 1fr 1fr; gap: 40px; flex:1;' });

    // Priority swatches
    const priorities = [
      ['Urgent', '#D32F2F', '#EF5350', 'Bold title, red left border, badge'],
      ['High', '#E64A19', '#FF6E40', 'Orange left border'],
      ['Medium', '#F9A825', '#FFD54F', 'Amber left border'],
      ['Low', '#90A4AE', '#607D8B', 'Subtle steel-blue border'],
      ['None', 'transparent', 'transparent', 'No visual treatment'],
    ];
    const priorityCol = h('div', {}, [
      h('h3', { style: 'font-size:14px; letter-spacing:0.16em; text-transform:uppercase; color:#999; margin:0 0 16px; font-weight:700;' }, 'Priority axis'),
      h('div', { style: 'display:flex; flex-direction:column; gap:10px;' },
        priorities.map(p => h('div', { style: 'display:flex; align-items:center; gap:14px; background:#141414; border-radius:10px; padding:10px 12px; border:1px solid rgba(255,255,255,0.06);' }, [
          h('div', { style: `width:4px; height:40px; background:${p[1]}; border-radius:2px; flex-shrink:0;` }),
          h('div', { style: 'flex:1;' }, [
            h('div', { style: 'font-size:14px; font-weight:600; color:#fff;' }, p[0]),
            h('div', { style: 'font-size:11px; color:rgba(255,255,255,0.55); margin-top:2px;' }, p[3])
          ]),
          h('div', { style: 'display:flex; gap:6px;' }, [
            h('div', { style: `width:16px; height:16px; border-radius:3px; background:${p[1]};` }),
            h('div', { style: `width:16px; height:16px; border-radius:3px; background:${p[2]};` }),
          ])
        ]))
      )
    ]);
    row.append(priorityCol);

    // Type scale
    const typeCol = h('div', {}, [
      h('h3', { style: 'font-size:14px; letter-spacing:0.16em; text-transform:uppercase; color:#999; margin:0 0 16px; font-weight:700;' }, 'Type scale'),
      h('div', { style: 'display:flex; flex-direction:column; gap:12px;' },
        [
          ['Display', '28', 'Bold', 'Onboarding'],
          ['Title L', '22', 'Semibold', 'Section headers'],
          ['Title M', '16', 'Semibold', 'Task titles'],
          ['Title urgent', '16', 'Bold', 'When urgent'],
          ['Body', '14', 'Regular', 'Notes, chips'],
          ['Label', '12', 'Medium', 'Chips, meta'],
          ['Small', '10', 'Medium', '+N, units'],
        ].map(t => h('div', { style: 'display:flex; align-items:baseline; gap:10px; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom:8px;' }, [
          h('span', { style: `font-size:${Math.min(parseInt(t[1])*0.8, 24)}px; font-weight:${t[2]==='Bold'?700:t[2]==='Semibold'?600:t[2]==='Medium'?500:400}; color:#fff; min-width:140px;` }, t[0]),
          h('span', { style: 'font-family:ui-monospace, monospace; font-size:11px; color:#888;' }, `${t[1]}sp · ${t[2]}`),
          h('span', { style: 'font-size:11px; color:#666; margin-left:auto;' }, t[3]),
        ]))
      )
    ]);
    row.append(typeCol);

    // Shape + iconography
    const shapeCol = h('div', {}, [
      h('h3', { style: 'font-size:14px; letter-spacing:0.16em; text-transform:uppercase; color:#999; margin:0 0 16px; font-weight:700;' }, 'Shape & rhythm'),
      h('div', { style: 'display:flex; flex-direction:column; gap:10px;' }, [
        ['Tile', '12dp radius · 1dp elev'],
        ['Sheet', '16dp top corners · drag handle'],
        ['FAB', 'Circular · 6dp elev'],
        ['Chip', '8dp radius · 1dp border'],
        ['Progress', '4dp tall · pill shape'],
        ['Priority stripe', '4dp wide · full height'],
      ].map(s => h('div', { style: 'display:flex; justify-content:space-between; align-items:center; background:#141414; padding:10px 12px; border-radius:8px; border:1px solid rgba(255,255,255,0.06);' }, [
        h('span', { style: 'font-size:13px; font-weight:600; color:#fff;' }, s[0]),
        h('span', { style: 'font-size:11px; color:#999;' }, s[1])
      ]))),
      h('h3', { style: 'font-size:14px; letter-spacing:0.16em; text-transform:uppercase; color:#999; margin:28px 0 12px; font-weight:700;' }, 'Bedtime escalation'),
      h('div', { style: 'display:flex; gap:8px;' }, [
        h('div', { style: 'flex:1; padding:10px; background:#141414; border-radius:8px; border:1px solid #00796B;' }, [
          h('div', { style: 'font-size:11px; color:#4DB6AC; font-weight:700;' }, 'DAY · CALM'),
          h('div', { style: 'font-size:11px; color:rgba(255,255,255,0.6); margin-top:4px;' }, 'Teal countdown chip')
        ]),
        h('div', { style: 'flex:1; padding:10px; background:#141414; border-radius:8px; border:1px solid #F57C00;' }, [
          h('div', { style: 'font-size:11px; color:#FFB300; font-weight:700;' }, 'T−2h · AMBER'),
          h('div', { style: 'font-size:11px; color:rgba(255,255,255,0.6); margin-top:4px;' }, 'Warning transition')
        ]),
        h('div', { style: 'flex:1; padding:10px; background:#141414; border-radius:8px; border:1px solid #D32F2F;' }, [
          h('div', { style: 'font-size:11px; color:#EF5350; font-weight:700;' }, 'T−30m · RED'),
          h('div', { style: 'font-size:11px; color:rgba(255,255,255,0.6); margin-top:4px;' }, 'Final push state')
        ]),
      ])
    ]);
    row.append(shapeCol);

    c.append(row);
    return c;
  }

  // ======================================================
  // Onboarding screens
  // ======================================================
  function onboard({ step, head, sub, body, ctas }) {
    const dots = h('div', { class: 'step-dots' }, [1,2,3,4].map(i => h('div', { class: 'dot' + (i === step ? ' active' : '') })));
    const wrap = h('div', { class: 'onboard' }, [
      h('div', { style: 'font-size:11px; letter-spacing:0.18em; text-transform:uppercase; color:var(--text-secondary); font-weight:600; margin-bottom:24px;' }, `Step ${step} of 4`),
      h('div', { class: 'ob-head' }, head),
      h('div', { class: 'ob-sub' }, sub),
      h('div', { class: 'ob-content' }, body),
      h('div', { style: 'display:flex; flex-direction:column; gap:10px;' }, ctas),
      dots
    ]);
    return wrap;
  }

  function timeWheel(hour, min, ampm) {
    return h('div', { class: 'time-wheel' }, [
      h('div', { class: 'wheel' }, [
        h('span', { class: 'ghost' }, String(hour - 1).padStart(2,'0')),
        h('span', { class: 'sel' }, String(hour).padStart(2,'0')),
        h('span', { class: 'ghost' }, String(hour + 1).padStart(2,'0')),
      ]),
      h('span', { class: 'sep' }, ':'),
      h('div', { class: 'wheel' }, [
        h('span', { class: 'ghost' }, String((min + 45) % 60).padStart(2,'0')),
        h('span', { class: 'sel' }, String(min).padStart(2,'0')),
        h('span', { class: 'ghost' }, String((min + 15) % 60).padStart(2,'0')),
      ]),
      h('div', { class: 'wheel', style: 'margin-left: 12px;' }, [
        h('span', { class: 'ghost' }, ampm === 'PM' ? 'AM' : 'PM'),
        h('span', { class: 'sel' }, ampm),
        h('span', { class: 'ghost', style: 'opacity:0;' }, '—'),
      ]),
    ]);
  }

  function onboardStep1() {
    return onboard({
      step: 1,
      head: 'When does your day end?',
      sub: 'DayDone schedules your reminders around your bedtime — so nothing slips.',
      body: h('div', { style: 'width:100%;' }, [
        timeWheel(11, 0, 'PM'),
        h('div', { style: 'text-align:center; font-size:11px; color:var(--text-secondary); margin-top: 12px; font-weight:500;' }, '6:00 PM  —  3:00 AM  ·  15-min steps')
      ]),
      ctas: [h('button', { class: 'btn-primary' }, 'Continue')]
    });
  }

  function onboardStep2() {
    return onboard({
      step: 2,
      head: 'When should we check in with you?',
      sub: 'A quick morning summary of what today holds.',
      body: h('div', { style: 'width:100%;' }, [
        timeWheel(8, 0, 'AM'),
      ]),
      ctas: [
        h('button', { class: 'btn-primary' }, 'Continue'),
        h('button', { class: 'btn-ghost' }, 'Skip for now')
      ]
    });
  }

  function onboardStep3() {
    const field = h('div', { style: 'width:100%; background:var(--surface); border-radius:14px; padding:18px; box-shadow: var(--shadow-tile); border:1px solid var(--divider); display:flex; flex-direction:column; gap:18px;' }, [
      h('div', {}, [
        h('div', { class: 'field-label' }, 'Task'),
        h('div', { class: 'input-line' }, 'Draft retrospective notes')
      ]),
      h('div', {}, [
        h('div', { class: 'field-label' }, 'Type'),
        h('div', { class: 'segmented' }, [
          h('div', { class: 'seg active' }, [mi('refresh', ''), 'Daily']),
          h('div', { class: 'seg' }, [mi('event', ''), 'One-time']),
        ])
      ]),
      h('div', {}, [
        h('div', { class: 'field-label' }, 'Priority'),
        h('div', { class: 'pills-row' }, [
          h('span', { class: 'priority-pill' }, 'None'),
          h('span', { class: 'priority-pill low' }, 'Low'),
          h('span', { class: 'priority-pill medium' }, 'Medium'),
          h('span', { class: 'priority-pill high active' }, 'High'),
          h('span', { class: 'priority-pill urgent' }, 'Urgent'),
        ])
      ]),
      h('div', {}, [
        h('div', { class: 'field-label' }, 'Label (optional)'),
        h('div', { class: 'input-box placeholder' }, '+ Add label')
      ])
    ]);

    return onboard({
      step: 3,
      head: 'Add your first task for today',
      sub: 'Just one thing. You can always add more.',
      body: field,
      ctas: [
        h('button', { class: 'btn-primary' }, 'Add Task'),
        h('button', { class: 'btn-ghost' }, 'Skip')
      ]
    });
  }

  function onboardStep4() {
    const illustration = h('div', { style: 'width:120px; height:120px; border-radius:50%; background: var(--primary-container); display:flex; align-items:center; justify-content:center; margin-bottom: 24px;' },
      (() => { const i = mi('notifications_active', 'filled'); i.style.fontSize = '64px'; i.style.color = 'var(--primary)'; return i; })()
    );
    return onboard({
      step: 4,
      head: 'DayDone needs to reach you — even on silent.',
      sub: '',
      body: h('div', { style: 'display:flex; flex-direction:column; align-items:center;' }, [
        illustration,
        h('div', { style: 'font-size:13px; color:var(--text-secondary); line-height:1.6; max-width:280px;' }, [
          h('p', { style: 'margin:0 0 10px;' }, 'You\'ll get a morning summary, a two-hour bedtime warning, and a final resolution prompt at lights-out.'),
          h('p', { style: 'margin:0 0 10px;' }, 'Reminders fire on your schedule — never random pings.'),
          h('p', { style: 'margin:0;' }, 'DND bypass is why the end-of-day mechanic works. Off means reminders are silent.'),
        ])
      ]),
      ctas: [
        h('button', { class: 'btn-primary' }, 'Allow Notifications'),
        h('button', { class: 'btn-ghost' }, 'Not now')
      ]
    });
  }

  // ======================================================
  // Today view
  // ======================================================
  function todayHeader({ greeting, date, pending, pendingError, countdown, countdownColor, progressDone, progressTotal }) {
    return h('div', { class: 'today-header' }, [
      h('div', { class: 'datestamp' }, date),
      h('h1', { class: 'greeting' }, greeting),
      h('div', { class: 'header-row' }, [
        h('span', { class: 'pending-badge' + (pendingError ? ' error' : '') }, pending),
        h('span', { class: 'countdown-chip ' + (countdownColor || '') }, [mi('schedule', ''), countdown])
      ]),
      h('div', { class: 'daily-progress' }, [
        h('div', { class: 'dp-labels' }, [h('span', {}, 'Daily progress'), h('span', {}, `${progressDone} of ${progressTotal} done`)]),
        h('div', { class: 'dp-track' }, [h('div', { class: 'dp-fill', style: `width:${Math.round((progressDone/progressTotal)*100)}%;` })])
      ])
    ]);
  }

  function todayNormalScreen() {
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    wrapper.append(todayHeader({
      date: 'SUN · APR 19', greeting: 'Good afternoon, Samir',
      pending: '4 pending', countdown: '4h 20m to bedtime',
      progressDone: 3, progressTotal: 7
    }));
    wrapper.append(filterBar([
      { label: 'All', active: true },
      { label: '⚑ Urgent' }, { label: 'High' }, { label: 'Medium' },
      { label: 'work' }, { label: 'health' },
    ]));
    const list = h('div', { class: 'list-scroll' });
    list.append(sectionHeader('PENDING · 4'));
    list.append(tile({ title: 'Submit launch copy to legal', priority: 'urgent', status: 'pending', chips: ['work', 'focus'] }));
    list.append(tile({ title: 'Run 5km before dinner', priority: 'high', status: 'pending', chips: ['health'], quant: { done: 3.0, total: 5.0, unit: 'km', pct: 60 } }));
    list.append(tile({ title: 'Reply to Priya about retro', priority: 'medium', status: 'pending', chips: ['work'], overdue: true }));
    list.append(tile({ title: 'Read 20 pages', priority: 'low', status: 'pending', chips: ['reading', 'evening', 'habit', 'focus'] }));
    list.append(sectionHeader('SNOOZED · 1'));
    list.append(tile({ title: 'Book dentist appointment', priority: 'none', status: 'snoozed', snoozedUntil: '4:00 PM' }));
    list.append(sectionHeader('DONE · 2'));
    list.append(tile({ title: 'Morning stretch routine', priority: 'low', status: 'done', chips: ['health'] }));
    list.append(tile({ title: 'Send weekly update', priority: 'medium', status: 'done', chips: ['work'] }));
    list.append(sectionHeader('CLOSED · 1'));
    list.append(tile({ title: 'Water the plants', priority: 'none', status: 'closed' }));

    wrapper.append(list);
    wrapper.append(h('div', { class: 'fab' }, mi('add', '')));
    wrapper.append(bottomNav('today'));
    return wrapper;
  }

  function todayUrgentScreen() {
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    wrapper.append(todayHeader({
      date: 'SUN · APR 19', greeting: 'Evening, Samir',
      pending: '2 pending', pendingError: true,
      countdown: '45m to bedtime', countdownColor: 'red',
      progressDone: 5, progressTotal: 7
    }));
    wrapper.append(h('div', { class: 'urgent-banner' }, [mi('bolt', 'filled'), '45 minutes until bedtime · 2 tasks remaining']));
    wrapper.append(filterBar([
      { label: 'All', active: true },
      { label: '⚑ Urgent' }, { label: 'High' }, { label: 'work' },
    ]));
    const list = h('div', { class: 'list-scroll' });
    list.append(sectionHeader('PENDING · 2'));
    list.append(tile({ title: 'Submit launch copy to legal', priority: 'urgent', status: 'pending', chips: ['work', 'focus'], urgentState: true }));
    list.append(tile({ title: 'Run 5km before dinner', priority: 'high', status: 'pending', chips: ['health'], quant: { done: 3.0, total: 5.0, unit: 'km', pct: 60 }, urgentState: true }));
    list.append(sectionHeader('DONE · 5'));
    list.append(tile({ title: 'Morning stretch routine', priority: 'low', status: 'done', chips: ['health'] }));
    list.append(tile({ title: 'Send weekly update', priority: 'medium', status: 'done', chips: ['work'] }));
    list.append(tile({ title: 'Reply to Priya about retro', priority: 'medium', status: 'done', chips: ['work'] }));

    wrapper.append(list);
    const fab = h('div', { class: 'fab', style: 'box-shadow: 0 6px 16px rgba(211,47,47,0.45), 0 0 0 8px rgba(211,47,47,0.18);' }, mi('add', ''));
    wrapper.append(fab);
    wrapper.append(bottomNav('today'));
    return wrapper;
  }

  function todayEmptyScreen() {
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    wrapper.append(h('div', { class: 'today-header' }, [
      h('div', { class: 'datestamp' }, 'MON · APR 13'),
      h('h1', { class: 'greeting' }, 'All done for today.'),
      h('div', { style: 'font-size:13px; color:var(--text-secondary); margin-top:6px;' }, 'Enjoy your evening.')
    ]));
    wrapper.append(h('div', { class: 'empty-state' }, [
      mi('task_alt', 'filled'),
      h('div', { class: 'em-title' }, 'All clear.'),
      h('div', { class: 'em-sub' }, 'Great work. Four tasks resolved before bedtime.'),
      h('div', { class: 'em-streak' }, ['🔥', 'Day 12 in a row']),
    ]));
    wrapper.append(h('div', { class: 'fab' }, mi('add', '')));
    wrapper.append(bottomNav('today'));
    return wrapper;
  }

  // ======================================================
  // Task create/edit
  // ======================================================
  function taskCreateScreen() {
    const content = h('div', { class: 'sheet' }, [
      h('div', { class: 'sheet-header' }, [
        h('div', { style: 'display:flex; align-items:center; gap:12px;' }, [
          mi('close', ''),
          h('div', { class: 'sheet-title' }, 'New Task')
        ]),
        h('div', { style: 'color:var(--primary); font-weight:700; font-size:14px;' }, 'Save')
      ]),
      h('div', { class: 'sheet-body', style: 'display:flex; flex-direction:column; gap:18px; overflow:hidden;' }, [
        // Title
        h('div', {}, [
          h('div', { style: 'display:flex; justify-content:space-between;' }, [
            h('div', { class: 'field-label' }, 'Title'),
            h('span', { style: 'font-size:10px; color:var(--text-disabled);' }, '24 / 200')
          ]),
          h('div', { class: 'input-line' }, 'Run 5km before dinner'),
        ]),
        // Type
        h('div', {}, [
          h('div', { class: 'field-label' }, 'Type'),
          h('div', { class: 'segmented' }, [
            h('div', { class: 'seg active' }, [mi('refresh', ''), 'Daily']),
            h('div', { class: 'seg' }, [mi('event', ''), 'One-time']),
          ])
        ]),
        // Priority
        h('div', {}, [
          h('div', { class: 'field-label' }, 'Priority'),
          h('div', { class: 'pills-row' }, [
            h('span', { class: 'priority-pill' }, 'None'),
            h('span', { class: 'priority-pill low' }, 'Low'),
            h('span', { class: 'priority-pill medium' }, 'Medium'),
            h('span', { class: 'priority-pill high active' }, 'High'),
            h('span', { class: 'priority-pill urgent' }, 'Urgent'),
          ])
        ]),
        // Labels
        h('div', {}, [
          h('div', { style: 'display:flex; justify-content:space-between;' }, [
            h('div', { class: 'field-label' }, 'Labels'),
            h('span', { style: 'font-size:10px; color:var(--text-disabled);' }, '2 / 5')
          ]),
          h('div', { style: 'display:flex; gap:6px; flex-wrap:wrap; align-items:center;' }, [
            h('span', { class: 'filter-chip active' }, ['health', ' ×']),
            h('span', { class: 'filter-chip active' }, ['evening', ' ×']),
            h('span', { class: 'filter-chip', style: 'color:var(--primary); border-color:var(--primary);' }, '+ Add label'),
          ])
        ]),
        // Quantified
        h('div', { style: 'padding:14px; background:var(--bg); border-radius:10px; border:1px solid var(--divider);' }, [
          h('div', { class: 'row-between' }, [
            h('div', {}, [
              h('div', { style: 'font-size:14px; font-weight:600;' }, 'Quantified task'),
              h('div', { style: 'font-size:11px; color:var(--text-secondary); margin-top:2px;' }, 'Set a numeric goal and track progress'),
            ]),
            h('div', { class: 'toggle on' }, h('div', { class: 'knob' }))
          ]),
          h('div', { style: 'display:flex; gap:10px; margin-top:12px;' }, [
            h('div', { style: 'flex:1;' }, [
              h('div', { class: 'field-label' }, 'Target'),
              h('div', { style: 'font-size:22px; font-weight:700; padding:8px 10px; background:var(--surface); border:1px solid var(--divider); border-radius:8px;' }, '5.0'),
            ]),
            h('div', { style: 'flex:1;' }, [
              h('div', { class: 'field-label' }, 'Unit'),
              h('div', { style: 'font-size:22px; font-weight:700; padding:8px 10px; background:var(--surface); border:1px solid var(--divider); border-radius:8px;' }, 'km'),
            ]),
          ]),
          h('div', { style: 'font-size:11px; color:var(--text-secondary); margin-top:10px;' }, '80% or more counts as done.')
        ]),
        // Pod visibility — disabled
        h('div', { class: 'row-between', style: 'opacity:0.5; padding:6px 0;' }, [
          h('div', {}, [
            h('div', { style: 'font-size:14px; font-weight:600;' }, ['Share with my pod ', h('span', { style: 'font-size:9px; background:var(--divider); color:var(--text-secondary); padding:2px 6px; border-radius:4px; margin-left:4px; font-weight:700;' }, 'SOON')]),
            h('div', { style: 'font-size:11px; color:var(--text-secondary); margin-top:2px;' }, 'Your pod will see this task\'s progress'),
          ]),
          h('div', { class: 'toggle' }, h('div', { class: 'knob' }))
        ]),
        h('div', { style: 'margin-top:6px;' }, h('button', { class: 'btn-primary' }, 'Save Task')),
      ])
    ]);
    return content;
  }

  // ======================================================
  // Bottom sheets
  // ======================================================
  function sheetBackdrop(bsheetNode, options = {}) {
    // Dim background with a ghost today-like content
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    // Replicate the today-ish background
    wrapper.append(todayHeader({
      date: 'SUN · APR 19', greeting: 'Good afternoon, Samir',
      pending: '4 pending', countdown: '4h 20m to bedtime',
      progressDone: 3, progressTotal: 7
    }));
    const list = h('div', { class: 'list-scroll' });
    list.append(sectionHeader('PENDING · 4'));
    list.append(tile({ title: 'Submit launch copy to legal', priority: 'urgent', status: 'pending' }));
    list.append(tile({ title: 'Run 5km before dinner', priority: 'high', status: 'pending', quant: {done:3,total:5,unit:'km',pct:60} }));
    list.append(tile({ title: 'Reply to Priya about retro', priority: 'medium', status: 'pending' }));
    wrapper.append(list);
    wrapper.append(bottomNav('today'));
    wrapper.append(h('div', { class: 'scrim' }));
    wrapper.append(bsheetNode);
    return wrapper;
  }

  function sheetA_Snooze() {
    const sheet = h('div', { class: 'bsheet' }, [
      h('div', { class: 'drag-handle' }),
      h('div', { class: 'bsheet-title' }, 'Snooze until…'),
      h('div', { class: 'opt-row' }, [mi('timer', ''), h('span', { style: 'flex:1;' }, '30 minutes'), h('span', { style: 'font-size:11px; color:var(--text-secondary);' }, '4:10 PM')]),
      h('div', { class: 'opt-row' }, [mi('schedule', ''), h('span', { style: 'flex:1;' }, '1 hour'), h('span', { style: 'font-size:11px; color:var(--text-secondary);' }, '4:40 PM')]),
      h('div', { class: 'opt-row' }, [mi('nightlight', ''), h('span', { style: 'flex:1;' }, '2 hours'), h('span', { style: 'font-size:11px; color:var(--text-secondary);' }, '5:40 PM')]),
      h('div', { class: 'opt-row' }, [mi('edit_calendar', ''), h('span', { style: 'flex:1;' }, 'Custom time…')]),
      h('div', { style: 'padding:14px 20px 4px; text-align:center;' }, h('span', { style: 'font-size:13px; font-weight:600; color:var(--text-secondary);' }, 'Cancel'))
    ]);
    return sheetBackdrop(sheet);
  }

  function sheetB_Context() {
    const sheet = h('div', { class: 'bsheet' }, [
      h('div', { class: 'drag-handle' }),
      h('div', { style: 'padding: 4px 20px 14px;' }, [
        h('div', { style: 'font-size:11px; color:var(--text-secondary); font-weight:600; text-transform:uppercase; letter-spacing:0.1em;' }, 'Task'),
        h('div', { style: 'font-size:15px; font-weight:600; color:var(--text-primary); margin-top:4px;' }, 'Run 5km before dinner'),
      ]),
      h('div', { style: 'border-top:1px solid var(--divider);' }),
      h('div', { class: 'opt-row' }, [mi('check_circle', 'filled'), 'Mark Done']),
      h('div', { class: 'opt-row' }, [mi('data_usage', ''), 'Log Progress']),
      h('div', { class: 'opt-row' }, [mi('schedule', ''), 'Snooze']),
      h('div', { class: 'opt-row' }, [mi('event', ''), 'Reschedule']),
      h('div', { class: 'opt-row' }, [mi('skip_next', ''), 'Skip Today']),
      h('div', { class: 'opt-row' }, [mi('edit', ''), 'Edit']),
      h('div', { style: 'border-top:1px solid var(--divider); margin: 4px 0;' }),
      h('div', { class: 'opt-row destructive' }, [mi('delete', ''), 'Delete']),
    ]);
    return sheetBackdrop(sheet);
  }

  function sheetC_Progress() {
    const sheet = h('div', { class: 'bsheet', style: 'padding-bottom: 24px;' }, [
      h('div', { class: 'drag-handle' }),
      h('div', { style: 'padding: 4px 20px 10px;' }, [
        h('div', { style: 'font-size:11px; color:var(--text-secondary); font-weight:600; text-transform:uppercase; letter-spacing:0.1em;' }, 'Log progress'),
        h('div', { style: 'font-size:16px; font-weight:700; color:var(--text-primary); margin-top:4px;' }, 'Run 5km before dinner'),
        h('div', { style: 'font-size:12px; color:var(--text-secondary); margin-top:4px;' }, 'Goal: 5.0 km  ·  Currently logged: 3.0 km')
      ]),
      h('div', { style: 'padding: 0 20px; display:flex; align-items:baseline; gap:10px; border-bottom:2px solid var(--primary); margin: 8px 20px 16px;' }, [
        h('input', { style: 'flex:1; font-size:48px; font-weight:700; border:none; background:transparent; padding:8px 0; color:var(--text-primary); outline:none; letter-spacing:-0.02em; min-width:0; width:100%;', value: '4.2' }),
        h('span', { style: 'font-size:18px; color:var(--text-secondary); font-weight:600;' }, 'km')
      ]),
      h('div', { style: 'padding: 0 20px;' }, [
        h('div', { style: 'height:6px; background:var(--divider); border-radius:3px; overflow:hidden;' }, h('div', { style: 'height:100%; width:84%; background:var(--progress-on-track); border-radius:3px;' })),
        h('div', { style: 'font-size:12px; color:var(--success); font-weight:600; margin-top:8px; display:flex; align-items:center; gap:4px;' }, [mi('check_circle', 'filled'), 'On track — counts as resolved']),
      ]),
      h('div', { style: 'padding: 16px 20px 0; display:flex; gap:10px;' }, [
        h('button', { class: 'btn-secondary', style: 'flex:1;' }, 'Cancel'),
        h('button', { class: 'btn-primary', style: 'flex:2;' }, 'Log Progress')
      ])
    ]);
    return sheetBackdrop(sheet);
  }

  function sheetD_EndOfDay() {
    const wrap = h('div', { style: 'height:100%; background:var(--surface-raised); display:flex; flex-direction:column; position:relative;' });
    wrap.append(h('div', { style: 'padding: 28px 20px 12px;' }, [
      h('div', { style: 'font-size:26px; font-weight:700; letter-spacing:-0.02em; color:var(--text-primary);' }, 'Before you sleep 💤'),
      h('div', { style: 'font-size:13px; color:var(--text-secondary); margin-top:6px; line-height:1.5;' }, 'These tasks are still unresolved. Give each one a final decision.'),
      h('div', { style: 'display:flex; align-items:center; gap:10px; margin-top: 16px;' }, [
        h('div', { style: 'flex:1; height:4px; background:var(--divider); border-radius:3px; overflow:hidden;' }, h('div', { style: 'height:100%; width:50%; background:var(--primary); border-radius:3px;' })),
        h('span', { style: 'font-size:11px; font-weight:700; color:var(--text-primary);' }, '2 of 4 resolved')
      ])
    ]));
    const list = h('div', { style: 'flex:1; padding-top: 8px;' });
    list.append(eodRow('Submit launch copy to legal', 'urgent', null, 'done'));
    list.append(eodRow('Run 5km before dinner', 'high', { done: 4.2, total: 5, unit: 'km' }, 'done'));
    list.append(eodRow('Reply to Priya about retro', 'medium', null, 'tomorrow'));
    list.append(eodRow('Read 20 pages', 'low', null, null));
    wrap.append(list);
    wrap.append(h('div', { style: 'padding: 12px 16px 20px;' }, h('button', { class: 'btn-primary', style: 'opacity:0.55;' }, 'All done')));
    return wrap;
  }

  function eodRow(title, priority, quant, selected) {
    const buttons = [
      { key: 'done', label: 'Done', icon: 'check' },
      { key: 'tomorrow', label: 'Tomorrow', icon: 'east' },
      { key: 'close', label: 'Close', icon: 'close' },
    ];
    const actions = h('div', { class: 'eod-actions' }, buttons.map(b =>
      h('div', { class: 'eod-btn' + (selected === b.key ? ` sel ${b.key}` : '') }, [
        mi(b.icon, ''), b.label
      ])
    ));
    const row = h('div', { class: 'eod-row ' + priority }, [
      h('div', { style: 'display:flex; justify-content:space-between; align-items:flex-start; gap:8px;' }, [
        h('div', { style: 'font-size:14px; font-weight:600; color:var(--text-primary); line-height:1.3;' }, title),
        quant ? h('span', { style: 'font-size:11px; color:var(--text-secondary); font-weight:600; white-space:nowrap;' }, `${quant.done}/${quant.total} ${quant.unit}`) : null
      ].filter(Boolean)),
      actions
    ]);
    return row;
  }

  // ======================================================
  // Calendar
  // ======================================================
  function calendarScreen() {
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    wrapper.append(h('div', { class: 'cal-header' }, [
      h('div', { class: 'cal-month' }, 'April 2026'),
      h('div', { class: 'cal-nav' }, [mi('chevron_left', ''), mi('chevron_right', '')])
    ]));

    // Build calendar grid
    const grid = h('div', { class: 'cal-grid' });
    ['S','M','T','W','T','F','S'].forEach(d => grid.append(h('div', { class: 'cal-dow' }, d)));
    // April 2026: starts Wednesday (assumed). We'll start with Mar 29 Sun for simplicity.
    const start = -2; // days offset
    for (let i = 0; i < 35; i++) {
      const day = start + i + 1;
      const isOther = day < 1 || day > 30;
      const dispDay = day < 1 ? (29 + day) : day > 30 ? (day - 30) : day;
      // Status dots: set some specific ones
      const statuses = {
        1: 'green', 2: 'green', 3: 'amber', 4: 'green', 5: 'grey', 6: 'green', 7: 'green',
        8: 'amber', 9: 'red', 10: 'green', 11: 'green', 12: 'green', 13: 'green',
        14: 'green', 15: 'amber', 16: 'green', 17: 'green', 18: 'green', 19: 'amber',
      };
      const status = !isOther ? statuses[day] : null;
      const isToday = day === 19;
      const isSelected = day === 17;
      const dotColor = {
        green: 'var(--success)', amber: 'var(--warning)', red: 'var(--error)', grey: 'var(--text-disabled)'
      }[status] || 'transparent';

      const cell = h('div', { class: 'cal-day' + (isOther ? ' other' : '') + (isToday ? ' today' : '') + (isSelected ? ' selected' : '') }, [
        h('span', {}, String(dispDay)),
        h('div', { class: 'dot', style: `background:${dotColor};` })
      ]);
      grid.append(cell);
    }
    wrapper.append(grid);

    wrapper.append(h('div', { style: 'border-top:1px solid var(--divider); padding: 16px 16px 8px;' }, [
      h('div', { style: 'font-size:11px; letter-spacing:0.14em; text-transform:uppercase; font-weight:600; color:var(--text-secondary);' }, 'Thu · Apr 17'),
      h('div', { style: 'font-size:17px; font-weight:700; color:var(--text-primary); margin-top:2px;' }, '3 tasks · all done'),
    ]));
    const list = h('div', { class: 'list-scroll' });
    list.append(tile({ title: 'Morning stretch routine', priority: 'low', status: 'done', chips: ['health'] }));
    list.append(tile({ title: 'Ship monthly report', priority: 'high', status: 'done', chips: ['work'] }));
    list.append(tile({ title: 'Read 20 pages', priority: 'low', status: 'done' }));
    wrapper.append(list);
    wrapper.append(h('div', { class: 'fab' }, mi('add', '')));
    wrapper.append(bottomNav('calendar'));
    return wrapper;
  }

  // ======================================================
  // Backlog
  // ======================================================
  function backlogScreen() {
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    wrapper.append(h('div', { style: 'padding: 16px 16px 10px;' }, [
      h('div', { style: 'font-size:22px; font-weight:700; letter-spacing:-0.01em; color:var(--text-primary);' }, 'All Tasks')
    ]));
    wrapper.append(filterBar([
      { label: 'All', active: true }, { label: 'Urgent' }, { label: 'High' }, { label: 'work' }, { label: 'health' }
    ]));

    const list = h('div', { class: 'list-scroll' });
    // Overdue
    list.append(h('div', { class: 'section-header overdue', style: 'padding-top:4px;' }, [
      h('span', {}, 'OVERDUE · 3'),
      h('span', { style: 'font-size:11px; color:var(--primary); font-weight:600; text-transform:none; letter-spacing:0;' }, 'Reschedule All')
    ]));
    list.append(tile({ title: 'File Q1 expense report', priority: 'urgent', status: 'pending', chips: ['work'], overdue: true }));
    list.append(tile({ title: 'Pay electricity bill', priority: 'high', status: 'pending', chips: ['home'], overdue: true }));
    list.append(tile({ title: 'Return library books', priority: 'low', status: 'pending', chips: ['errand'], overdue: true }));

    list.append(sectionHeader('MON · APR 20'));
    list.append(tile({ title: 'Team planning sync', priority: 'high', status: 'pending', chips: ['work'] }));
    list.append(tile({ title: 'Grocery run', priority: 'low', status: 'pending', chips: ['home'] }));

    list.append(sectionHeader('WED · APR 22'));
    list.append(tile({ title: 'Dentist appointment', priority: 'medium', status: 'pending', chips: ['health'] }));

    list.append(sectionHeader('THU · APR 24'));
    list.append(tile({ title: 'Submit Q2 OKRs', priority: 'urgent', status: 'pending', chips: ['work'] }));

    wrapper.append(list);
    wrapper.append(h('div', { class: 'fab' }, mi('add', '')));
    wrapper.append(bottomNav('backlog'));
    return wrapper;
  }

  // ======================================================
  // Reports
  // ======================================================
  function reportsScreen() {
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative; overflow:hidden;' });
    wrapper.append(h('div', { style: 'padding: 16px 16px 10px;' }, [
      h('div', { style: 'display:flex; align-items:center; justify-content:space-between;' }, [
        h('div', { style: 'font-size:22px; font-weight:700; letter-spacing:-0.01em; color:var(--text-primary);' }, 'Progress'),
        mi('filter_list', '')
      ]),
      h('div', { style: 'display:inline-flex; align-items:center; gap:4px; margin-top:8px; padding:6px 10px; border-radius:999px; background:var(--divider); font-size:12px; font-weight:600;' }, ['Apr 12 – Apr 18', mi('keyboard_arrow_down', '')])
    ]));

    const scroll = h('div', { style: 'flex:1; overflow:hidden;' });

    // Stats
    scroll.append(h('div', { class: 'report-card' }, h('div', { class: 'stat-grid' }, [
      h('div', { class: 'stat-item' }, [h('div', { class: 'num' }, '42'), h('div', { class: 'lbl' }, 'Tasks created')]),
      h('div', { class: 'stat-item' }, [h('div', { class: 'num green' }, '34'), h('div', { class: 'lbl' }, 'Completed')]),
      h('div', { class: 'stat-item' }, [h('div', { class: 'num grey' }, '5'), h('div', { class: 'lbl' }, 'Closed')]),
      h('div', { class: 'stat-item' }, [h('div', { class: 'num green' }, '81%'), h('div', { class: 'lbl' }, 'Overall rate')]),
    ])));

    // Chart
    const chartCard = h('div', { class: 'report-card' });
    chartCard.append(h('div', { style: 'font-size:13px; font-weight:700; color:var(--text-primary); margin-bottom:8px;' }, 'Daily completion'));
    const bars = [65, 80, 100, 85, 50, 100, 75];
    const chart = h('div', { class: 'chart' });
    chart.append(h('div', { class: 'ref-line', style: 'right:0; top:20%;' }));
    bars.forEach((v, i) => {
      const color = v >= 80 ? 'var(--success)' : v >= 50 ? 'var(--warning)' : 'var(--error)';
      const isToday = i === 6;
      chart.append(h('div', { class: 'bar', style: `height:${v}%; background:${color}; opacity:${isToday ? 0.6 : 1}; ${isToday ? 'outline: 1.5px dashed '+color+'; outline-offset:-1.5px;' : ''}` }));
    });
    chartCard.append(chart);
    chartCard.append(h('div', { style: 'display:flex; justify-content:space-between; margin-top:6px; font-size:10px; color:var(--text-secondary);' },
      ['12','13','14','15','16','17','today'].map(x => h('span', {}, x))
    ));
    scroll.append(chartCard);

    // Streak row
    scroll.append(h('div', { style: 'display:flex; gap:10px; margin: 0 16px 12px;' }, [
      h('div', { style: 'flex:1; background:var(--surface); border:1px solid var(--divider); border-radius:14px; padding:14px;' }, [
        h('div', { style: 'font-size:20px;' }, '🔥'),
        h('div', { style: 'font-size:11px; color:var(--text-secondary); text-transform:uppercase; letter-spacing:0.08em; font-weight:600; margin-top:6px;' }, 'Current streak'),
        h('div', { style: 'font-size:24px; font-weight:700; color:var(--text-primary); margin-top:2px;' }, '12 days'),
      ]),
      h('div', { style: 'flex:1; background:var(--surface); border:1px solid var(--divider); border-radius:14px; padding:14px;' }, [
        h('div', { style: 'font-size:20px;' }, '🏆'),
        h('div', { style: 'font-size:11px; color:var(--text-secondary); text-transform:uppercase; letter-spacing:0.08em; font-weight:600; margin-top:6px;' }, 'Longest streak'),
        h('div', { style: 'font-size:24px; font-weight:700; color:var(--text-primary); margin-top:2px;' }, '21 days'),
      ]),
    ]));

    // By Priority
    const prCard = h('div', { class: 'report-card' });
    prCard.append(h('div', { style: 'font-size:13px; font-weight:700; color:var(--text-primary); margin-bottom:10px;' }, 'By priority'));
    [['urgent','Urgent',5,4,1,'80%'],['high','High',12,10,2,'83%'],['medium','Medium',14,12,2,'86%'],['low','Low',11,8,3,'73%']].forEach(r => {
      prCard.append(h('div', { style: 'display:grid; grid-template-columns: 14px 1fr repeat(3, 28px) 40px; gap:10px; align-items:center; padding:6px 0; font-size:12px; border-top: 1px solid var(--divider);' }, [
        h('div', { style: `width:10px; height:10px; background:var(--p-${r[0]}); border-radius:2px;` }),
        h('span', { style: 'font-weight:600; color:var(--text-primary);' }, r[1]),
        h('span', { style: 'color:var(--text-secondary); text-align:right;' }, String(r[2])),
        h('span', { style: 'color:var(--success); text-align:right;' }, String(r[3])),
        h('span', { style: 'color:var(--text-secondary); text-align:right;' }, String(r[4])),
        h('span', { style: 'font-weight:700; color:var(--text-primary); text-align:right;' }, r[5]),
      ]));
    });
    scroll.append(prCard);

    wrapper.append(scroll);
    wrapper.append(bottomNav('reports'));
    return wrapper;
  }

  // ======================================================
  // Settings
  // ======================================================
  function settingsScreen() {
    const wrapper = h('div', { style: 'height:100%; display:flex; flex-direction:column;' });
    wrapper.append(h('div', { style: 'padding: 16px 20px 4px;' }, h('div', { style: 'font-size:22px; font-weight:700; letter-spacing:-0.01em; color:var(--text-primary);' }, 'Settings')));

    const scroll = h('div', { style: 'flex:1; overflow:hidden;' });

    const group = (label, rows) => {
      const g = h('div', {});
      g.append(h('div', { class: 'settings-group-label' }, label));
      rows.forEach(r => g.append(r));
      return g;
    };

    const row = (label, value, opts = {}) => h('div', { class: 'settings-row' + (opts.disabled ? ' disabled' : '') }, [
      h('div', {}, [
        h('div', { class: 'label' }, opts.badge ? [label, ' ', h('span', { style: 'font-size:9px; background:var(--warning); color:#fff; padding:2px 6px; border-radius:4px; margin-left:6px; font-weight:700;' }, opts.badge)] : label),
        opts.sub ? h('div', { class: 'sub' }, opts.sub) : null
      ].filter(Boolean)),
      value === 'toggle-on' ? h('div', { class: 'toggle on' }, h('div', { class: 'knob' })) :
      value === 'toggle-off' ? h('div', { class: 'toggle' }, h('div', { class: 'knob' })) :
      h('div', { class: 'val' }, [value, mi('chevron_right', '')])
    ]);

    scroll.append(group('Schedule', [
      row('Bedtime', '11:00 PM'),
      row('Morning Check-in', '8:00 AM'),
      row('Notification Frequency', 'Standard'),
    ]));
    scroll.append(group('Appearance', [
      row('Theme', 'System'),
    ]));
    scroll.append(group('Notifications', [
      row('Notification Permission', 'Allowed'),
      row('DND Override', 'toggle-on', { sub: 'Required for bedtime push on silent' }),
    ]));
    scroll.append(group('Progress', [
      row('View Progress', ''),
    ]));
    scroll.append(group('Accountability Pod', [
      row('My Pod', '', { disabled: true, badge: 'SOON' }),
    ]));
    scroll.append(group('About', [
      row('App Version', '1.0.0'),
      row('Privacy Policy', ''),
      row('Send Feedback', ''),
    ]));

    wrapper.append(scroll);
    wrapper.append(bottomNav('settings'));
    return wrapper;
  }

  // ======================================================
  // Pod
  // ======================================================
  function podEmpty() {
    const wrap = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    wrap.append(h('div', { style: 'padding: 16px 20px 4px;' }, h('div', { style: 'font-size:22px; font-weight:700; color:var(--text-primary);' }, 'Pod')));
    wrap.append(h('div', { style: 'flex:1; display:flex; align-items:center; justify-content:center; padding: 16px;' },
      h('div', { class: 'pod-card', style: 'width:100%;' }, [
        (() => { const i = mi('group', 'filled'); i.style.fontSize = '52px'; i.style.color = 'var(--primary)'; return i; })(),
        h('div', { style: 'font-size:20px; font-weight:700; margin-top:12px; letter-spacing:-0.01em; color:var(--text-primary);' }, 'Up to 5 people.'),
        h('div', { style: 'font-size:14px; color:var(--text-primary); margin-top:4px;' }, 'Daily accountability. No strangers.'),
        h('div', { style: 'font-size:12px; color:var(--text-secondary); margin-top:10px; line-height:1.5;' }, 'Your pod sees today\'s progress — not your tasks, not your notes. Just whether you got it done.'),
        h('div', { style: 'margin-top:20px; display:flex; flex-direction:column; gap:8px;' }, [
          h('button', { class: 'btn-primary' }, 'Create a pod'),
          h('button', { class: 'btn-secondary' }, 'Join with invite link'),
        ])
      ])
    ));
    wrap.append(bottomNav('settings'));
    return wrap;
  }

  function podActive() {
    const wrap = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
    wrap.append(h('div', { style: 'padding: 16px 20px 4px;' }, [
      h('div', { style: 'display:flex; justify-content:space-between; align-items:center;' }, [
        h('div', {}, [
          h('div', { style: 'font-size:11px; letter-spacing:0.14em; text-transform:uppercase; font-weight:600; color:var(--text-secondary);' }, 'Pod'),
          h('div', { style: 'font-size:22px; font-weight:700; color:var(--text-primary);' }, 'The Grind Squad'),
        ]),
        mi('more_vert', '')
      ])
    ]));

    const ring = (initials, pct, color) => {
      const svg = `<svg viewBox="0 0 56 56"><circle cx="28" cy="28" r="24" fill="none" stroke="currentColor" stroke-width="3" stroke-opacity="0.15"/><circle cx="28" cy="28" r="24" fill="none" stroke="${color}" stroke-width="3" stroke-linecap="round" stroke-dasharray="${(pct/100) * 150.8} 150.8" transform="rotate(-90 28 28)"/></svg>`;
      return h('div', { class: 'member-card' }, [
        h('div', { class: 'ring', html: svg + `<div class='initials'>${initials}</div>` }),
        h('div', { style: 'font-size:12px; font-weight:600; color:var(--text-primary);' }, initials === 'SA' ? 'You' : initials === 'AL' ? 'Alex' : initials === 'PR' ? 'Priya' : initials === 'JM' ? 'Jamie' : 'Reese'),
        h('div', { style: 'font-size:10px; color:var(--text-secondary);' }, `${pct}%`)
      ]);
    };

    const row = h('div', { class: 'member-row', style: 'padding-top: 12px;' }, [
      ring('SA', 60, '#F9A825'),
      ring('AL', 100, '#388E3C'),
      ring('PR', 40, '#F9A825'),
      ring('JM', 100, '#388E3C'),
      ring('RE', 20, '#D32F2F'),
    ]);
    wrap.append(row);

    wrap.append(h('div', { style: 'font-size:11px; letter-spacing:0.14em; text-transform:uppercase; font-weight:700; color:var(--text-secondary); padding: 8px 20px;' }, "Today's activity"));
    const activity = [
      ['Alex completed all tasks 🎉', '2h ago', 'var(--success)'],
      ['Priya has \"Run 5km\" at 2/5 km — 1h left', '12m ago', 'var(--warning)'],
      ['Jamie wrapped up early today', '3h ago', 'var(--success)'],
      ['You have 3 tasks remaining', 'now', 'var(--primary)'],
      ['Reese missed yesterday', '1d ago', 'var(--error)'],
    ];
    activity.forEach(a => wrap.append(h('div', { class: 'activity-row' }, [
      h('div', { class: 'dot', style: `background:${a[2]};` }),
      h('div', { style: 'flex:1;' }, [
        h('div', {}, a[0]),
        h('div', { class: 'time' }, a[1])
      ])
    ])));

    wrap.append(h('div', { style: 'flex:1;' }));
    wrap.append(bottomNav('settings'));
    return wrap;
  }

  // ======================================================
  // Edge states
  // ======================================================
  function edgeStatesSlide() {
    const c = h('div', { class: 'slide-content', style: 'background:#0a0a0a; padding: 56px 64px; display:flex; flex-direction:column; gap:28px; height:100%;' });
    c.append(h('div', {}, [
      h('div', { class: 'slide-eyebrow' }, 'Edge & empty states'),
      h('h1', { class: 'slide-title' }, 'Eight edges, handled with care.'),
    ]));

    const makeMini = (content, mode = 'light') => {
      const m = h('div', { class: 'mini-phone' + (mode === 'dark' ? ' dark' : '') });
      const s = h('div', { class: 'screen' });
      s.append(content);
      m.append(s);
      return m;
    };

    const edges = [
      {
        cap: 'Today — no tasks yet',
        sub: 'Centered FAB arrow cue points to creation.',
        content: (() => {
          const w = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
          w.append(h('div', { style: 'padding: 16px 16px 0;' }, [
            h('div', { style: 'font-size:10px; letter-spacing:0.14em; color:var(--text-secondary); font-weight:600; text-transform:uppercase;' }, 'SUN · APR 19'),
            h('div', { style: 'font-size:20px; font-weight:700; color:var(--text-primary);' }, 'Your day is empty.')
          ]));
          w.append(h('div', { class: 'empty-state' }, [
            mi('add_task', ''),
            h('div', { class: 'em-title' }, 'Nothing yet.'),
            h('div', { class: 'em-sub' }, 'Add your first task to get started →')
          ]));
          w.append(h('div', { class: 'fab', style: 'bottom: 20px;' }, mi('add', '')));
          w.append(bottomNav('today'));
          return w;
        })()
      },
      {
        cap: 'Notif permission denied',
        sub: 'Persistent amber banner at top of Today.',
        content: (() => {
          const w = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
          w.append(h('div', { style: 'padding: 16px 16px 0;' }, [
            h('div', { style: 'font-size:10px; letter-spacing:0.14em; color:var(--text-secondary); font-weight:600; text-transform:uppercase;' }, 'Today'),
            h('div', { style: 'font-size:20px; font-weight:700; color:var(--text-primary);' }, 'Hi, Samir')
          ]));
          w.append(h('div', { class: 'banner', style: 'margin-top:10px;' }, [
            mi('warning', ''),
            h('div', { style: 'flex:1; font-size:11px;' }, [h('div', { style: 'font-weight:700;' }, 'Reminders are off'), h('div', {}, 'DayDone can\'t reach you.')]),
            h('span', { style: 'font-size:11px; font-weight:700; color:var(--warning);' }, 'Enable'),
            mi('close', '')
          ]));
          const list = h('div', { class: 'list-scroll' });
          list.append(tile({ title: 'Submit report', priority: 'urgent', status: 'pending' }));
          list.append(tile({ title: 'Run 5km', priority: 'high', status: 'pending', quant: {done:3,total:5,unit:'km',pct:60} }));
          w.append(list);
          w.append(bottomNav('today'));
          return w;
        })()
      },
      {
        cap: 'Overdue tasks badge',
        sub: '"From yesterday" chip prepended to title.',
        content: (() => {
          const w = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
          w.append(h('div', { style: 'padding: 16px 16px 0;' }, h('div', { style: 'font-size:20px; font-weight:700; color:var(--text-primary);' }, 'Today')));
          const list = h('div', { class: 'list-scroll', style: 'margin-top: 12px;' });
          list.append(sectionHeader('PENDING · 3'));
          list.append(tile({ title: 'Reply to Priya about retro', priority: 'medium', status: 'pending', overdue: true }));
          list.append(tile({ title: 'Pay electricity bill', priority: 'high', status: 'pending', overdue: true }));
          list.append(tile({ title: 'Call dentist', priority: 'low', status: 'pending' }));
          w.append(list);
          w.append(bottomNav('today'));
          return w;
        })()
      },
      {
        cap: 'Battery optimization (Android)',
        sub: 'Full-screen modal explains OEM quirk.',
        content: (() => {
          const w = h('div', { style: 'height:100%; background: var(--surface-overlay); position:relative; display:flex; align-items:center; justify-content:center; padding: 16px;' });
          w.append(h('div', { style: 'background:var(--surface-raised); border-radius:20px; padding:24px; color:var(--text-primary); display:flex; flex-direction:column; gap:14px;' }, [
            (() => { const i = mi('battery_alert', 'filled'); i.style.fontSize='40px'; i.style.color='var(--warning)'; return i; })(),
            h('div', { style: 'font-size:18px; font-weight:700; letter-spacing:-0.01em;' }, 'One more step.'),
            h('div', { style: 'font-size:12px; color:var(--text-secondary); line-height:1.5;' }, 'Your phone kills background apps to save battery. To deliver bedtime reminders, DayDone needs to be exempted.'),
            h('button', { class: 'btn-primary' }, 'Open battery settings'),
            h('button', { class: 'btn-ghost' }, 'Dismiss')
          ]));
          return w;
        })()
      },
      {
        cap: 'Reports — no data',
        sub: 'Gentle prompt to widen range.',
        content: (() => {
          const w = h('div', { style: 'height:100%; display:flex; flex-direction:column;' });
          w.append(h('div', { style: 'padding: 16px 16px 0;' }, h('div', { style: 'font-size:20px; font-weight:700; color:var(--text-primary);' }, 'Progress')));
          w.append(h('div', { class: 'empty-state' }, [
            mi('insights', ''),
            h('div', { class: 'em-title' }, 'No tasks in this period.'),
            h('div', { class: 'em-sub' }, 'Try a different date range or add tasks today.')
          ]));
          w.append(bottomNav('reports'));
          return w;
        })()
      },
      {
        cap: 'Reports — no filter matches',
        sub: 'Different message from empty-range.',
        content: (() => {
          const w = h('div', { style: 'height:100%; display:flex; flex-direction:column;' });
          w.append(h('div', { style: 'padding: 16px 16px 6px;' }, h('div', { style: 'font-size:20px; font-weight:700; color:var(--text-primary);' }, 'Progress')));
          w.append(h('div', { style: 'display:flex; gap:6px; padding: 0 16px 10px; flex-wrap:wrap;' }, [
            h('span', { class: 'filter-chip active' }, 'label: work ×'),
            h('span', { class: 'filter-chip active' }, 'priority: urgent ×'),
          ]));
          w.append(h('div', { class: 'empty-state' }, [
            mi('filter_alt_off', ''),
            h('div', { class: 'em-title' }, 'No tasks match.'),
            h('div', { class: 'em-sub' }, 'Try removing a filter to see more.')
          ]));
          w.append(bottomNav('reports'));
          return w;
        })()
      },
      {
        cap: 'Large date range (>90d)',
        sub: 'Inline info banner under picker.',
        content: (() => {
          const w = h('div', { style: 'height:100%; display:flex; flex-direction:column;' });
          w.append(h('div', { style: 'padding: 16px 16px 6px;' }, [
            h('div', { style: 'font-size:20px; font-weight:700; color:var(--text-primary);' }, 'Progress'),
            h('div', { style: 'display:inline-flex; align-items:center; gap:4px; margin-top:8px; padding:6px 10px; border-radius:999px; background:var(--divider); font-size:12px; font-weight:600; color:var(--text-primary);' }, ['Jan 1 – Apr 19', mi('keyboard_arrow_down', '')]),
          ]));
          w.append(h('div', { class: 'banner', style: 'margin-top: 8px;' }, [
            mi('info', ''),
            h('span', { style: 'font-size:11px;' }, 'Large ranges may take a moment to load.')
          ]));
          w.append(h('div', { style: 'flex:1; display:flex; align-items:center; justify-content:center; color:var(--text-secondary); font-size:12px;' }, 'Loading 108 days…'));
          w.append(bottomNav('reports'));
          return w;
        })()
      },
      {
        cap: 'All done early (before T−1h)',
        sub: 'Green celebration banner.',
        content: (() => {
          const w = h('div', { style: 'height:100%; display:flex; flex-direction:column; position:relative;' });
          w.append(h('div', { style: 'padding: 16px 16px 0;' }, [
            h('div', { style: 'font-size:10px; letter-spacing:0.14em; color:var(--text-secondary); font-weight:600; text-transform:uppercase;' }, 'SUN · APR 19'),
            h('div', { style: 'font-size:20px; font-weight:700; color:var(--text-primary);' }, 'Hi, Samir')
          ]));
          w.append(h('div', { class: 'banner success', style: 'margin-top:10px;' }, [
            h('span', { style: 'font-size:20px;' }, '🎉'),
            h('div', { style: 'flex:1; font-size:11px;' }, [h('div', { style: 'font-weight:700;' }, 'You finished everything early!'), h('div', {}, 'Enjoy your evening.')]),
          ]));
          const list = h('div', { class: 'list-scroll', style: 'margin-top: 8px;' });
          list.append(sectionHeader('DONE · 5'));
          list.append(tile({ title: 'Morning stretch', priority: 'low', status: 'done' }));
          list.append(tile({ title: 'Ship update', priority: 'medium', status: 'done' }));
          w.append(list);
          w.append(bottomNav('today'));
          return w;
        })()
      },
    ];

    const grid = h('div', { class: 'edge-grid' });
    edges.forEach(e => {
      grid.append(h('div', { class: 'edge-card' }, [
        makeMini(e.content),
        h('div', { class: 'cap' }, e.cap),
        h('div', { class: 'sub' }, e.sub),
      ]));
    });
    c.append(grid);
    return c;
  }

  // ======================================================
  // Component sheet (5 priorities x 4 statuses)
  // ======================================================
  function componentSheet() {
    const c = h('div', { class: 'slide-content', style: 'background:#0a0a0a; padding: 56px 60px; display:flex; flex-direction:column; gap:24px; height:100%;' });
    c.append(h('div', {}, [
      h('div', { class: 'slide-eyebrow' }, 'Component sheet'),
      h('h1', { class: 'slide-title' }, 'Task tile · 5 priorities × 4 statuses'),
      h('p', { class: 'slide-subtitle', style: 'margin-top:10px;' }, 'Every state the core UI unit can be in, in both modes. Priority axis is visual; status axis is behavioral.'),
    ]));

    const priorities = ['urgent','high','medium','low','none'];
    const statuses = ['pending','done','closed','snoozed'];

    const makeRow = (mode) => {
      const table = h('div', { style: 'display:grid; grid-template-columns: 90px repeat(4, 1fr); gap: 8px; margin-bottom: 18px;' });
      // header
      table.append(h('div', { style: `font-size:10px; letter-spacing:0.14em; text-transform:uppercase; font-weight:600; color:${mode==='dark'?'#888':'#888'}; padding:4px;` }, mode === 'light' ? 'Light' : 'Dark'));
      statuses.forEach(s => table.append(h('div', { style: `font-size:10px; letter-spacing:0.12em; text-transform:uppercase; font-weight:700; color:#fff; padding:4px; text-align:center;` }, s)));

      priorities.forEach(p => {
        table.append(h('div', { style: `font-size:11px; font-weight:700; color:#ccc; padding: 8px 4px; text-transform: capitalize; display:flex; align-items:center; gap:6px;` }, [
          h('div', { style: `width:4px; height:18px; background:var(--p-${p}, transparent); border-radius:2px;` }),
          p
        ]));
        statuses.forEach(s => {
          const wrap = h('div', { class: 'comp-tile-wrap' + (mode === 'dark' ? ' dark' : '') });
          wrap.append(tile({
            title: s === 'pending' ? 'Run 5km before dinner' : s === 'done' ? 'Morning stretch done' : s === 'closed' ? 'Water plants — skipped' : 'Book dentist',
            priority: p,
            status: s,
            snoozedUntil: s === 'snoozed' ? '4:00 PM' : null,
          }));
          table.append(wrap);
        });
      });
      return table;
    };

    const container = h('div', { style: 'display:grid; grid-template-columns: 1fr 1fr; gap: 40px; flex:1;' });
    const col1 = h('div', { class: 'light' }, makeRow('light'));
    const col2 = h('div', { class: 'dark' }, makeRow('dark'));
    container.append(col1, col2);
    c.append(container);
    return c;
  }

  // ======================================================
  // Token sheets
  // ======================================================
  function tokenSheet(mode) {
    const c = h('div', { class: 'slide-content' + (mode === 'dark' ? ' dark' : ''), style: `background:#0a0a0a; padding: 56px 64px; display:flex; flex-direction:column; gap:24px; height:100%;` });
    c.append(h('div', {}, [
      h('div', { class: 'slide-eyebrow' }, 'Color tokens'),
      h('h1', { class: 'slide-title' }, mode === 'light' ? 'Light mode reference' : 'Dark mode reference'),
    ]));

    const TOKENS = mode === 'light' ? [
      ['Surface', [
        ['background', '#F5F5F3'],
        ['surface', '#FFFFFF'],
        ['surface-raised', '#FFFFFF'],
        ['surface-overlay', 'rgba(20,18,16,0.45)'],
        ['nav-bg', '#FFFFFF'],
      ]],
      ['Text', [
        ['text-primary', '#1A1A1A'],
        ['text-secondary', '#6B6B6B'],
        ['text-disabled', '#B8B8B8'],
        ['text-on-accent', '#FFFFFF'],
        ['divider', 'rgba(0,0,0,0.07)'],
      ]],
      ['Priority', [
        ['p-urgent', '#D32F2F'],
        ['p-high', '#E64A19'],
        ['p-medium', '#F9A825'],
        ['p-low', '#90A4AE'],
        ['p-none', 'transparent'],
      ]],
      ['Semantic', [
        ['success / progress-done', '#388E3C'],
        ['warning / progress-partial', '#F57C00'],
        ['error', '#D32F2F'],
        ['info', '#1976D2'],
      ]],
      ['Interactive', [
        ['primary', '#00796B'],
        ['primary-container', '#E0F2F1'],
        ['secondary', '#546E7A'],
        ['nav-indicator', '#E0F2F1'],
      ]],
    ] : [
      ['Surface', [
        ['background', '#121212'],
        ['surface', '#1E1E1E'],
        ['surface-raised', '#2C2C2C'],
        ['surface-overlay', 'rgba(0,0,0,0.6)'],
        ['nav-bg', '#1E1E1E'],
      ]],
      ['Text', [
        ['text-primary', '#FAFAFA'],
        ['text-secondary', '#A0A0A0'],
        ['text-disabled', '#5A5A5A'],
        ['text-on-accent', '#FFFFFF'],
        ['divider', 'rgba(255,255,255,0.08)'],
      ]],
      ['Priority', [
        ['p-urgent', '#EF5350'],
        ['p-high', '#FF6E40'],
        ['p-medium', '#FFD54F'],
        ['p-low', '#607D8B'],
        ['p-none', 'transparent'],
      ]],
      ['Semantic', [
        ['success / progress-done', '#66BB6A'],
        ['warning / progress-partial', '#FFB300'],
        ['error', '#EF5350'],
        ['info', '#64B5F6'],
      ]],
      ['Interactive', [
        ['primary', '#4DB6AC'],
        ['primary-container', '#0F3530'],
        ['secondary', '#78909C'],
        ['nav-indicator', '#0F3530'],
      ]],
    ];

    const grid = h('div', { style: 'display:grid; grid-template-columns: 1fr 1fr 1fr; gap: 40px; flex:1;' });
    TOKENS.forEach(([groupName, rows]) => {
      const col = h('div', {});
      col.append(h('h4', { style: 'font-size:12px; letter-spacing:0.14em; text-transform:uppercase; color:#999; margin:0 0 12px; font-weight:700;' }, groupName));
      rows.forEach(([name, hex]) => {
        col.append(h('div', { style: 'display:flex; align-items:center; gap:12px; padding:10px; background:rgba(255,255,255,0.04); border-radius:8px; margin-bottom:6px; border:1px solid rgba(255,255,255,0.06);' }, [
          h('div', { style: `width:28px; height:28px; border-radius:6px; background:${hex}; border:1px solid rgba(255,255,255,0.1); flex-shrink:0;` }),
          h('div', { style: 'flex:1;' }, [
            h('div', { style: 'font-size:12px; font-weight:600; color:#fff;' }, name),
            h('div', { style: 'font-size:10px; color:#888; font-family:ui-monospace, monospace; margin-top:2px;' }, hex),
          ])
        ]));
      });
      grid.append(col);
    });
    c.append(grid);
    return c;
  }

  // ======================================================
  // Populate sections
  // ======================================================
  const builders = [
    null, // cover already authored
    () => buildDesignSystem(),
    () => slideShell({ eyebrow: 'Onboarding · 1 of 4', title: 'Bedtime setup.', subtitle: 'The first number DayDone needs to know. Everything else schedules around it.', light: () => onboardStep1(), dark: () => onboardStep1(), notes: ['Drum-roll wheel with ghost neighbors and a solid selected row — reinforces the tactility of "this is the number that matters".', 'No skip on step 1 — bedtime is load-bearing for the core mechanic.', 'Step dots: 20dp wide pill for active, 6dp circles for others.'] }),
    () => slideShell({ eyebrow: 'Onboarding · 2 of 4', title: 'Morning check-in.', subtitle: 'Optional but opinionated. A gentle intro to your day, not an alarm clock replacement.', light: () => onboardStep2(), dark: () => onboardStep2(), notes: ['Same picker style preserves the muscle memory from step 1.', 'Skip for now is a ghost button, not a text-as-nav afterthought.'] }),
    () => slideShell({ eyebrow: 'Onboarding · 3 of 4', title: 'Your first task.', subtitle: 'Prove the tile anatomy in the first 60 seconds — priority pills, type toggle, labels.', light: () => onboardStep3(), dark: () => onboardStep3(), notes: ['Inline creation = no modal-within-onboarding. The new-task card is the one they\'ll meet again every day.', 'Priority pills use their final color — first contact with the priority axis.'] }),
    () => slideShell({ eyebrow: 'Onboarding · 4 of 4', title: 'Notifications matter.', subtitle: 'The entire bedtime mechanic collapses without DND override. Three paragraphs that earn the permission.', light: () => onboardStep4(), dark: () => onboardStep4(), notes: ['Abstracted bell icon inside a primary-container circle — no literal illustration, just mass + color.', 'Body text is framed as the product promising scheduled (not random) pings.'] }),

    () => slideShell({ eyebrow: 'Today · Normal state · 3 PM · 4 pending', title: 'Today — calm, mid-afternoon.', subtitle: 'Most-used screen. Pending-first, grouped by status. Bedtime countdown is teal until T−2h.', light: () => todayNormalScreen(), dark: () => todayNormalScreen(), notes: ['Header: datestamp eyebrow, greeting, pending badge + countdown chip, daily progress bar.', 'Grouping: Pending → Snoozed (dimmed) → Done (strike) → Closed (grey strike).', 'Quantified tile: progress bar fills left-to-right, amber until 80%, green at ≥80%.', 'Overdue task: red "From yesterday" chip inline with the title.'] }),
    () => slideShell({ eyebrow: 'Today · Urgent state · T−45m · 2 pending', title: 'Today — 45 minutes to bedtime.', subtitle: 'Priority borders hold full saturation; pending tiles pick up a red-tinted surface wash. FAB gets a pulse halo.', light: () => todayUrgentScreen(), dark: () => todayUrgentScreen(), notes: ['Full-width red urgent banner below the header. Bedtime chip is red, pending badge is red.', 'Red-to-surface gradient wash on urgent pending tiles — subtle on light, stronger on dark.', 'FAB pulse is a static red ring here; annotate for Flutter as breathing animation.'] }),
    () => slideShell({ eyebrow: 'Today · Empty state · all resolved', title: 'Today — all clear.', subtitle: 'Quiet celebration. Streak chip surfaces only when ≥ 2.', light: () => todayEmptyScreen(), dark: () => todayEmptyScreen(), notes: ['Icon over illustration — Material Symbols task_alt, filled, primary color.', 'Streak chip uses warning-tinted background; fire emoji as brand touch.'] }),

    () => slideShell({ eyebrow: 'Task create / edit', title: 'Creation sheet.', subtitle: 'Single column, 18dp gaps, 16dp edge padding. Quantified is a prominent card, not a buried toggle.', light: () => taskCreateScreen(), dark: () => taskCreateScreen(), notes: ['Title uses an underline input (primary color) — echoes Material 3 without being literal.', 'Priority pills preview final treatment: high is filled orange when active.', 'Pod visibility is rendered but visibly disabled with a SOON badge — honest about roadmap.', 'Character counters only appear on focus in the live app; shown here for spec clarity.'] }),

    () => slideShell({ eyebrow: 'Bottom sheet · A', title: 'Snooze picker.', subtitle: 'Four rows, resolved times on the right so the decision is concrete. Custom opens inline.', light: () => sheetA_Snooze(), dark: () => sheetA_Snooze(), notes: ['Sheet overlays the Today view with a scrim (surface-overlay).', 'Resolved time on the right ("4:10 PM") removes mental math.'] }),
    () => slideShell({ eyebrow: 'Bottom sheet · B', title: 'Task context menu.', subtitle: 'Task title fixed at top. Destructive action isolated below a divider.', light: () => sheetB_Context(), dark: () => sheetB_Context(), notes: ['Conditional rows (Log Progress, Reschedule, Skip Today) only render when the task type supports them.', 'Delete is red, last, and separated — friction that prevents mis-taps.'] }),
    () => slideShell({ eyebrow: 'Bottom sheet · C', title: 'Log quantified progress.', subtitle: 'Giant number input. Progress bar updates live. Status line below tells the user where they stand.', light: () => sheetC_Progress(), dark: () => sheetC_Progress(), notes: ['Input uses an underline at 2dp to match the create sheet.', 'Status line swaps: "Not quite there" → "On track — counts as resolved" → "Goal exceeded!".', 'Primary button carries heavier weight (flex:2) than Cancel (flex:1).'] }),
    () => slideShell({ eyebrow: 'Bottom sheet · D · full screen', title: 'End-of-day resolution.', subtitle: 'Not dismissable by swipe. Each unresolved task needs a final verdict before "All done" unlocks.', light: () => sheetD_EndOfDay(), dark: () => sheetD_EndOfDay(), notes: ['Top progress: "2 of 4 resolved" updates live as the user makes choices.', 'Selected verdict fills the pill in its color: success, info, or text-secondary.', 'All done button is disabled until every task has a selection — prevents a hurried dismissal.'] }),

    () => slideShell({ eyebrow: 'Calendar', title: 'Month + day view.', subtitle: 'Compact grid with per-day status dots. Selecting a day swaps the lower list.', light: () => calendarScreen(), dark: () => calendarScreen(), notes: ['Dot legend: green = all done, amber = partial, red = missed, grey = no tasks.', 'Today: outlined ring. Selected: filled primary circle. Both can coexist.', 'Past days: read-only; future: dated tasks only in pending state.'] }),
    () => slideShell({ eyebrow: 'Backlog · all dated tasks', title: 'All tasks, grouped by date.', subtitle: 'Overdue always at the top with its own "Reschedule All" affordance.', light: () => backlogScreen(), dark: () => backlogScreen(), notes: ['Sticky date section headers as the user scrolls.', 'Overdue header text is red; action link is primary.', 'Same tile anatomy as Today — one component, many views.'] }),
    () => slideShell({ eyebrow: 'Reports', title: 'Progress — calm analytics.', subtitle: 'Not a dashboard explosion. 4 stats, one chart, two streak tiles, two breakdown tables.', light: () => reportsScreen(), dark: () => reportsScreen(), notes: ['Date range pill is tappable → inline Material 3 range picker.', 'Today bar: dashed outline + lower opacity so it reads as "in progress".', 'Dashed reference line at 80% — the success threshold everywhere in the app.'] }),
    () => slideShell({ eyebrow: 'Settings', title: 'Preferences, grouped.', subtitle: 'Six groups, uppercase section labels. Pod is visibly disabled with a SOON badge.', light: () => settingsScreen(), dark: () => settingsScreen(), notes: ['Rows share surface color; divider is a hairline; group labels sit in a slightly tinted strip above.', 'Toggles use primary color when on — same one everywhere.'] }),

    () => slideShell({ eyebrow: 'Pod · State A · empty', title: 'Accountability pod — no members yet.', subtitle: 'Primary-container card frames the pitch. Two CTAs: create, or join via link.', light: () => podEmpty(), dark: () => podEmpty(), notes: ['Frames the social promise: "No strangers. Daily. Just whether you got it done."', 'Create is primary; join is secondary.'] }),
    () => slideShell({ eyebrow: 'Pod · State B · active', title: 'Pod — members + feed.', subtitle: 'Completion ring around each avatar — the key metaphor. Activity feed below.', light: () => podActive(), dark: () => podActive(), notes: ['Ring color: green ≥80%, amber ≥50%, red <50%. Arc length = completion %.', 'Activity feed uses color dots that echo the ring states.', 'Pull-to-refresh (annotated in code) syncs pod data.'] }),

    () => edgeStatesSlide(),
    () => componentSheet(),
    () => tokenSheet('light'),
    () => tokenSheet('dark'),
  ];

  // Build
  for (let i = 0; i < sections.length; i++) {
    if (i === 0) continue; // cover is authored inline
    const b = builders[i];
    if (b) sections[i].appendChild(b());
    else sections[i].textContent = 'TODO';
  }
})();

# UX Design Spec: {feature-name}

**Status:** Draft — Pending Approval
**Feature Directory:** {PLAN}
**Prototype Reference:** [`{PLAN}/../prototypes/`] _(or "None — written spec only", or path to a reused sibling prototype)_
**Companion Document:** [prd.md](./prd.md)
**Standards Reference:** _(list any design-system / accessibility-guideline files this spec inherits from)_

---

## 1. Purpose
_(2–3 paragraphs. State what user-facing surfaces this spec defines and why a UX spec exists separately from the PRD and the architecture. The PRD says **what** the feature is; the architecture says **how** the code is shaped; this spec says **how it should look and behave** in the user's hands. Name the prototype(s) if any, and what they cover.)_

---

## 2. Visual Language
### 2.1 Inheritance from Existing UI
_(Name the product's existing visual language this spec extends. Identify the palette, typography, spacing, and shape conventions it inherits unchanged. List file references if inheritance is enforced by shared style tokens.)_

### 2.2 Extensions or New Motifs (if any)
_(Anything this feature introduces that is genuinely new — a new state color, a new component variant, a new transition timing. Justify each. If none, write "None — this feature uses the existing language unchanged".)_

### 2.3 Tokens Specific to This Feature
_(Concrete values for any feature-specific tokens. Quote sizes from design/accessibility standards verbatim — do not invent. If none, write "None — uses existing tokens".)_

---

## 3. Surface Inventory
_(One-paragraph overview of every UI surface this feature introduces or modifies. A "surface" is anything the user perceives as a distinct UI element: a page/view, an overlay panel, a modal dialog, an inline panel, a toast. The table below is the index; each row links to its own section.)_

| # | Surface | Type | When it appears | When it dismisses | Blocks interaction? |
|---|---------|------|-----------------|-------------------|---------------------|
| 3.1 | _(name)_ | _(page / overlay / modal / inline / toast)_ | _(trigger)_ | _(trigger)_ | _(yes/no)_ |

### 3.1 _(Surface name)_
**Type:** _(page / view / overlay / modal / inline panel / toast)_
**Anchor:** _(where it lives — e.g. "full page", "centered modal", "right-side drawer")_
**Footprint:** _(rough size in plain words — "two-column form", "centered modal at ~40% viewport width")_
**Interaction blocking:** _(does it block the rest of the UI? does it trap focus?)_

#### Content
_(Describe the regions of this surface in user-visible terms. List sub-elements in reading order.)_

#### Sizing
_(Only sizes mandated by design/accessibility standards or load-bearing for layout — body text size, hit-area minimums, gaps. Pixel-perfect coordinates live in the prototype CSS.)_

#### Behavior
_(How this surface responds to user actions, what dynamic content it shows, what other surfaces it opens or closes.)_

_(Repeat §3.x for each surface in the inventory.)_

---

## 4. Layout
### 4.1 Composition
_(How this feature's surfaces compose with the rest of the product's UI. Ordering rules when multiple surfaces are visible at once. Responsive behavior across breakpoints if applicable.)_

### 4.2 Responsive / Mode Variations (if applicable)
_(If the feature behaves differently across breakpoints or modes — e.g. mobile vs desktop — describe the layout per mode. Otherwise write N/A.)_

---

## 5. Interaction Patterns
### 5.1 Focus & Keyboard Model
For each focusable surface from §3:
- **Initial focus on open:** _(which element receives focus — name the role, not the component)_
- **Focus restoration on close:** _(focus returns to the element that opened this surface — or specify otherwise)_
- **Focus trapping:** _(does the surface trap focus inside its bounds? — required for modals)_
- **Navigation:** _(tab order and arrow-key behavior, including edge behavior: wrap vs clamp)_

### 5.2 Visual States
| Element | Default | Hover | Focus | Selected | Disabled | Error |
|---------|---------|-------|-------|----------|----------|-------|
| _(element)_ | _(state)_ | _(...)_ | _(visible focus indicator)_ | _(...)_ | _(...)_ | _(...)_ |

_(Mark cells N/A for states that do not apply, with a one-line rationale.)_

### 5.3 Confirm / Cancel / Destructive Contract
- **Confirm:** _(action + which surfaces use it)_
- **Cancel:** _(action + does it ever destroy state or only dismiss?)_
- **Destructive (delete/discard):** _(action + does it open a confirm dialog first?)_
- **Safe defaults:** _(for destructive confirms, which option is auto-focused?)_

### 5.4 Empty / Loading / Error States
For surfaces that present dynamic data:
- **Empty:** _(what the user sees when the data set is empty)_
- **Loading:** _(spinner? skeleton? optimistic UI? nothing?)_
- **Error:** _(what the user sees on action failure — toast? inline message? both?)_

### 5.5 Transitions & Timing
_(How surfaces open, close, and update. Easing style, duration, whether motion is snapped or smooth. Quote the product's existing convention if one exists. Note motion-reduction behavior.)_

---

## 6. Accessibility
**WCAG target:** _(e.g. WCAG 2.1 AA)_

| Concern | Standard | This feature |
|---------|----------|--------------|
| Color contrast | _(quote standard)_ | _(this feature)_ |
| Keyboard operation | _(full keyboard reachability)_ | _(this feature)_ |
| Screen reader | _(labels/roles/announcements)_ | _(this feature)_ |
| Hit-area / target size | _(quote standard)_ | _(this feature)_ |

### 6.1 Standards Deviations (if any)
_(If any element violates a standard, name it, name the standard, and justify. Otherwise: "No deviations".)_

### 6.2 Additional Notes
_(Motion-reduction alternatives, font-scaling support, focus-visible behavior. Skip if not applicable.)_

---

## 7. PRD Traceability
| PRD requirement | Surface / pattern that satisfies it |
|-----------------|-------------------------------------|
| _(FR-N or AC-N from prd.md)_ | _(reference into this spec, e.g. §3.2, §5.2)_ |

_(Every UI-touching PRD requirement appears in this table. Conversely, every surface in this spec maps back to at least one PRD requirement — if a surface has no row, either remove it or add the PRD requirement.)_

---

## 8. Open Design Questions
_(Things the spec deliberately leaves undecided. The architect must NOT invent an answer. Each question identifies who or what will resolve it.)_

| Question | Why deferred | Who/what resolves it |
|----------|--------------|----------------------|
| _(...)_ | _(user test, design review, sponsor decision, ...)_ | _(...)_ |

---

## 9. Out of Scope (UX-side)
_(UI work explicitly NOT covered by this spec, to prevent scope creep. Adjacent but not part of this feature.)_

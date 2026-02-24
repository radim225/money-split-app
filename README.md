# Money Split

A clean, modern iOS app for splitting group expenses among friends — inspired by Settle Up.

## Screenshots

_Coming soon_

---

## Architecture

**Pattern:** MVVM (Model-View-ViewModel)
**Framework:** SwiftUI + SwiftData
**Platform:** iOS 18+
**Language:** Swift 6 (strict concurrency)

```
MoneySplit/
├── App/               Entry point, constants
├── Models/            SwiftData @Model classes
├── ViewModels/        @MainActor ObservableObject VMs
├── Views/
│   ├── Groups/        Groups list + create/edit
│   ├── Dashboard/     Overview, charts, category breakdown
│   ├── Members/       Member management + detail
│   ├── Expenses/      Expense list + add/edit form
│   ├── Balances/      Net balances + settlement suggestions
│   └── Shared/        Reusable components
├── Services/          Pure business logic
└── Resources/         Assets, preview data
```

---

## Data Model

```
SplitGroup          ──┐
  id, name, emoji      │ cascade
  colorHex             │
  currencyCode         ▼
  members: [Member]  Member
  expenses: [Expense]  id, name, avatarColorHex

                     Expense            ──┐
                       id, title           │ cascade
                       amountCents (Int)   │
                       categoryId          ▼
                       payerId (UUID)    ExpenseSplit
                       splits: [...]       id, memberId (UUID)
                                           amountCents (Int)
```

**All monetary amounts are stored as `Int` (minor units / cents) to avoid floating-point precision issues.** Displayed via `CurrencyFormatter` which uses `Decimal` arithmetic.

---

## Balance Calculation

For each member in a group:

```
paidTotal  = Σ expense.amountCents  where expense.payerId == member.id
shareTotal = Σ split.amountCents    where split.memberId  == member.id
netBalance = paidTotal - shareTotal

  netBalance > 0  →  others owe this member
  netBalance < 0  →  this member owes others
  netBalance = 0  →  settled
```

### Settlement Minimization

Uses a greedy algorithm to produce the **minimum number of transactions** needed to settle all debts:

1. Partition into creditors (net > 0) and debtors (net < 0), sorted by absolute value
2. Match the largest creditor with the largest debtor
3. Transfer `min(|creditor|, |debtor|)`, reduce both balances
4. Re-insert any remainder, repeat until empty

---

## Split Modes

| Mode   | Logic |
|--------|-------|
| Equal  | `base = total / count`, remainder → first member. Sum always equals total. |
| Manual | User enters each share. Real-time validation: shows unassigned/over amount. Save disabled until balanced. |

---

## Setup

### Prerequisites
- Xcode 16+ (iOS 18 SDK)
- Homebrew

### Install & Run

```bash
# 1. Install xcodegen
brew install xcodegen

# 2. Generate Xcode project
cd "Money split app"
xcodegen generate

# 3. Open in Xcode
open MoneySplit.xcodeproj
```

Then build and run on simulator or device (iOS 18+).

---

## MVP Features

- [x] Multiple groups with emoji/color customization
- [x] Group members with avatar colors
- [x] Add/edit/delete expenses
- [x] Equal or manual split per expense
- [x] Single payer per expense
- [x] Balance calculation (paid / share / net)
- [x] Settlement suggestions (minimize transactions)
- [x] Dashboard with Swift Charts (donut + bar charts)
- [x] Per-member detail view
- [x] Category breakdown
- [x] Filter/sort expenses
- [x] SwiftData persistence
- [x] Dark Mode support

## Future Improvements

- [ ] Multiple payers per expense
- [ ] Split by percentages or shares/weights
- [ ] Multiple currencies per group with conversion
- [ ] Cloud sync (iCloud / CloudKit)
- [ ] Export / share expense summary (PDF, CSV)
- [ ] Recurring expenses
- [ ] Custom categories
- [ ] Push notifications for new expenses
- [ ] Widget for current balance

---

## Tech Notes

- **No external dependencies** — pure Apple frameworks only (SwiftUI, SwiftData, Swift Charts)
- **Swift 6 strict concurrency** — all ViewModels are `@MainActor`, no data races
- **SwiftData relationships** — `@Relationship(deleteRule: .cascade)` on owner side only; `payerId` and `memberId` are stored as `UUID` (denormalized) to avoid nullable relationship fragility
- **Currency math** — `Int` cents everywhere, `Decimal` only at display boundary via `NumberFormatter`

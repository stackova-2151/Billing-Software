# 🚀 Quick Start Guide - Stock & Expense Management

## 📦 Stock Management

### Access
Navigate to **"Stock"** from the sidebar

### Features

#### View Stock Status
- **Green Badge** = In Stock (above threshold)
- **Orange Badge** = Low Stock (at or below threshold)
- **Red Badge** = Out of Stock (0 quantity)

#### Add Stock
1. Click **"Add / Update Stock"** button (top-right)
2. Select item from dropdown
3. Enter quantity to add
4. Optionally set low stock threshold
5. Click **"Update Stock"**

#### Quick Add
- Click the **green + icon** next to any item
- Enter quantity
- Click **"Add"**

#### Automatic Stock Reduction
- Stock automatically reduces when you print a bill
- If insufficient stock, order will be blocked with error message

---

## 💰 Expense Management

### Access
Navigate to **"Expenses"** from the sidebar

### Features

#### View Expenses
- See total expenses at the top
- View all expenses in chronological order
- Each expense shows: title, amount, date, and note

#### Add Expense
1. Click **"Add Expense"** button (top-right)
2. Enter title (required)
3. Enter amount (required, must be > 0)
4. Select date using date picker
5. Optionally add a note
6. Click **"Add Expense"**

#### Delete Expense
- Click the **delete icon** on any expense
- Confirm deletion in the dialog

---

## 🔄 Integration with Orders

### How It Works
1. Customer places order
2. Items added to cart
3. Click **"Print Bill"**
4. System checks stock availability
5. If sufficient stock:
   - Stock is reduced
   - Bill is printed
   - Order is saved
6. If insufficient stock:
   - Error message shown
   - Order is blocked
   - No stock is reduced

### Error Messages
- **"Insufficient stock for [Item Name]. Available: X, Required: Y"**
- This prevents overselling

---

## 📊 Best Practices

### Stock Management
1. Set realistic low stock thresholds (e.g., 10-20 units)
2. Monitor low stock items regularly
3. Restock before items go out of stock
4. Check stock status before busy periods

### Expense Management
1. Add expenses daily for accuracy
2. Use clear, descriptive titles
3. Add notes for important details
4. Review total expenses regularly

---

## 🎯 Common Tasks

### Task: Check Low Stock Items
1. Go to Stock screen
2. Look for **orange badges**
3. Click + icon to add stock

### Task: Add Daily Expenses
1. Go to Expenses screen
2. Click "Add Expense"
3. Fill in details
4. Submit

### Task: View Today's Expenses
1. Go to Expenses screen
2. Check total at top
3. Scroll through list

---

## ⚠️ Important Notes

1. **Stock cannot go negative** - Orders will be blocked
2. **Expenses cannot be edited** - Delete and re-add if needed
3. **All changes are real-time** - Updates reflect immediately
4. **Stock reduces on print** - Not when adding to cart

---

## 🆘 Troubleshooting

### "Insufficient stock" error
- Check stock quantity in Stock screen
- Add more stock before placing order

### Expense not showing
- Check if date is correct
- Refresh the screen

### Stock not updating
- Check internet connection
- Verify Firestore permissions

---

## 📱 Navigation

```
Sidebar Menu:
├── Dashboard
├── Point of Sale
├── Menu Items
├── Bills History
├── Reports
├── Stock          ← NEW
├── Expenses       ← NEW
└── Profile
```

---

## ✅ Quick Checklist

Before opening for business:
- [ ] Check stock levels
- [ ] Restock low items
- [ ] Review yesterday's expenses
- [ ] Verify all items have stock thresholds set

End of day:
- [ ] Add all expenses
- [ ] Check stock levels
- [ ] Note items to restock tomorrow

---

**Need Help?** Refer to STOCK_EXPENSE_IMPLEMENTATION.md for detailed technical documentation.

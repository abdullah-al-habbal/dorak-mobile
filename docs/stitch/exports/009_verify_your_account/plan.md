## 1. Understanding the Export (`009_verify_your_account`)

**What’s in the folder:**
- `DESIGN.md` – global tokens (already implemented; **do not regenerate**).
- `code.html` – the screen layout and behavior source.

**Screen Purpose:**  
A verification screen where users enter a 6‑digit OTP sent to their email/phone to confirm their account. It follows the sign‑up screen (008) and precedes account completion (home or onboarding).

**Layout & Behavior (from HTML):**
- **Header:** Back button (arrow_back) + brand text “Dorak”.
- **Main content** (card with backdrop‑blur, max‑width 480px):
  - Icon: `mark_email_read` (email open) – use `Icons.mark_email_read` or `Icons.email`.
  - Title: “Verify Your Account”.
  - Subtitle: “Enter the 6‑digit code we sent to j***@example.com” – includes masked email/phone (we'll use a parameter).
  - 6 OTP input fields (each maxLength=1, auto‑focus, auto‑advance, backspace handling).
  - Error message container (hidden by default; shows with error icon and text when verification fails).
  - Verify button (primary, full‑width).
  - Resend code button (with countdown timer, initially disabled).
- **Animation:** The card fades‑in‑up with 0.1s delay (single group). We can use a single `FadeTransition` for the entire card content, or split header and form – but only one delay is indicated, so one animation is sufficient.
- **No background blobs** (only a subtle decorative circle in the card itself – can be ignored or implemented as a simple `Container` with gradient/opacity).

---

## 2. Implementation Plan (Step‑by‑Step)

### 2.1. Feature & File Structure
Add to the existing `auth` feature folder:
```
apps/client_app/lib/src/features/auth/
├── verify_account.screen.dart              (NEW) – StatefulWidget with single animation
├── widgets/
│   ├── verify_account_content.widget.dart  (NEW) – Stateless? Actually stateful to manage OTP fields, timer, error.
│   ├── otp_input_field.widget.dart         (NEW) – custom widget for a single OTP digit input (reusable).
│   └── ... (others from previous exports)
```

### 2.2. Localization (ARB)
Add the following keys to **both** `app_en.arb` and `app_ar.arb`. Reuse existing keys where possible.

| Key | English | Arabic |
|-----|---------|--------|
| `verifyTitle` | "Verify Your Account" | "تحقق من حسابك" |
| `verifySubtitle` | "Enter the 6-digit code we sent to {email}" | "أدخل الرمز المكون من 6 أرقام الذي أرسلناه إلى {email}" |
| `verifyCodeLabel` (optional) | "Verification Code" | "رمز التحقق" |
| `verifyButton` | "Verify & Continue" | "تحقق واستمر" |
| `verifyResend` | "Resend Code" | "إعادة إرسال الرمز" |
| `verifyResendDisabled` | "Resend Code ({seconds}s)" | "إعادة إرسال الرمز ({seconds}ث)" |
| `verifyErrorInvalid` | "Invalid code. Please try again." | "رمز غير صحيح. يرجى المحاولة مرة أخرى." |
| `verifyDidNotReceive` | "Didn't receive the code?" | "لم تستلم الرمز؟" |

Also, we need the masked email/phone to be passed as a parameter (string). We'll use a placeholder like `{email}` in the ARB string.

After editing, run `flutter gen-l10n` in `packages/localization`.

### 2.3. Screen Implementation (`verify_account.screen.dart`)

- **StatefulWidget** with `SingleTickerProviderStateMixin`.
- Define an `AnimationController` (600 ms) and a single `CurvedAnimation` (interval 0.0–0.8) – or just one animation for the whole content.
- Scaffold with `backgroundColor: DorakColors.of(context).background`.
- Use a `Stack` with a `SafeArea` containing a `Column`:
  - **Header**: `Row` with Back button + Spacer + brand text "Dorak" + Spacer (for balance).
  - **Main content**: `Expanded` with `Center` containing a `Container` (the card) with:
    - `decoration: BoxDecoration` with `color: colors.surface.withOpacity(0.7)`, `borderRadius: BorderRadius.circular(16)`, `border: Border.all(color: Colors.white.withOpacity(0.4))`, `boxShadow: [BoxShadow(...)]`.
    - Inside: a `Padding` with the `VerifyAccountContent` widget.
- Apply `FadeTransition` with the single animation to the card (or to the whole content area). We can wrap the `Center` with `FadeTransition`.

### 2.4. Content Widget (`verify_account_content.widget.dart`)

This widget will be **stateful** because it manages OTP fields, timer, error state. It receives:
- `String emailOrPhone` (the masked string to display in subtitle).
- `VoidCallback onBack` (for back button? Actually back is in the screen header; we can pass onBack to screen).
- `Future<bool> Function(String code) onVerify` (async validation).
- `Future<void> Function() onResend` (async resend).

**State:**
- `List<TextEditingController> _controllers` (6).
- `List<FocusNode> _focusNodes` (6).
- `String _errorMessage` (null if no error).
- `int _resendCooldown` (seconds, 60 initially, or 0 if ready).
- `Timer? _timer`.
- `bool _isVerifying` (loading state for verify button).
- `bool _isResending` (loading for resend).

**Build:**
- `Column` with:
  - Icon: `Icon(Icons.mark_email_read, size: 48, color: colors.primary)`.
  - Title: `Text(l10n.verifyTitle, style: DorakTypography.headlineLgMobile)` (or headlineLg).
  - Subtitle: `Text(l10n.verifySubtitle.replaceFirst('{email}', emailOrPhone))` – use `Text.rich` or simple replacement.
  - `SizedBox(height: 24)`.
  - **OTP Row**: `Row` with 6 `OtpInputField` widgets, each linked to a controller and focus node. Use `Expanded` with `SizedBox(width: 4)` between them.
  - **Error message**: `Container` with `height: 24`, `child: Visibility(visible: _errorMessage != null, child: Row(...))` with error icon + `Text(_errorMessage)`.
  - **Verify button**: `PrimaryButton` with `onPressed: _verify`, `isLoading: _isVerifying`.
  - **Resend row**: `Row` with `Text(l10n.verifyDidNotReceive)` and a `TextButton` (or `GestureDetector`) with `onPressed: _resendCode`, disabled when `_resendCooldown > 0`. Show cooldown as `l10n.verifyResendDisabled` if > 0 else `l10n.verifyResend`.

**Logic:**
- `initState`: set up controllers, focus nodes, start cooldown (60 seconds) and timer.
- `dispose`: dispose controllers, focus nodes, cancel timer.
- `_onOtpChanged`: when a field’s text changes, if length==1, move focus to next; if backspace and empty, move to previous.
- `_verify`: validate length == 6, call `onVerify(code)` (async). On success, navigate to home (or call onSuccess callback). On failure, set error message.
- `_resendCode`: call `onResend()`, reset cooldown to 60, start timer again.

### 2.5. Custom OTP Input Field (`otp_input_field.widget.dart`)

- Stateless widget that takes `TextEditingController`, `FocusNode`, `bool autoFocus`, `ValueChanged<String> onChanged`.
- Build a `TextField` with:
  - `maxLength: 1`,
  - `textAlign: TextAlign.center`,
  - `keyboardType: TextInputType.number`,
  - `decoration: InputDecoration` with no border? Actually we need a bottom border underline style. Use `UnderlineInputBorder` with `outlineVariant` color, and when focused, `primary` color. Also set `filled: true`, `fillColor: colors.surfaceContainerLow.withOpacity(0.5)`, and `borderRadius: BorderRadius.circular(4)`? The HTML uses `rounded` but with bottom border; we can use `OutlineInputBorder` with `borderSide: BorderSide.none` and `enabledBorder`, `focusedBorder` set to `UnderlineInputBorder` to get underline. But for consistency with design system, we might create a custom style.
  - Alternatively, use a `Container` with a `TextFormField` and custom decoration. We'll keep it simple: use `TextField` with `decoration: InputDecoration(border: UnderlineInputBorder())` and customize colors.
- On changed, call `onChanged` with the new value (single digit).

### 2.6. Navigation Wiring

- In `sign_up.screen.dart`: after successful sign‑up (stub), push `VerifyAccountScreen`:
  ```dart
  Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyAccountScreen(
    emailOrPhone: emailPhone, // e.g., "j***@example.com"
    onVerify: (code) async {
      // stub: check code == "123456" for demo, then return true
      if (code == '123456') {
        // navigate to home
        _goHome();
        return true;
      }
      return false;
    },
    onResend: () async {
      // stub: simulate resend, maybe reset timer.
    },
  )));
  ```
- The verify screen has its own back button that pops.
- On successful verification, we can either replace the stack or navigate to home (onboarding) – we'll call a provided callback or use `Navigator.pushReplacement` to home.

### 2.7. Additional Considerations

- **Masked email**: The sign‑up screen will pass the email/phone (e.g., "john@example.com") to the verify screen, which will mask it (e.g., "j***@example.com") before display. We can do that in the screen by extracting the first character and domain.
- **Cooldown timer**: The HTML starts with 0:59, so we start cooldown at 60 seconds immediately when the screen loads. That simulates that the code was already sent.
- **Error state**: The error container has a fixed height to avoid layout shift. We'll use `SizedBox(height: 24)` with `Visibility` to show/hide.
- **Focus management**: After the screen loads, auto‑focus on the first field (we can use `FocusScope.of(context).requestFocus(_focusNodes[0])` with a post‑frame callback).

### 2.8. Verification Gate

After implementation:
1. Run `flutter gen-l10n` (if ARB changed).
2. Run `flutter analyze` on `client_app`.
3. Run `flutter test` (if any tests added).
4. Run `dart run tool/check_taxonomy.dart`.

All must pass.

### 2.9. Cleanup

After verification, delete the export folder:  
`dorak-mobile/docs/stitch/exports/009_verify_your_account/` (including `code.html` and `DESIGN.md`).

---

## 3. Deliverable Instructions for the AI Agent

Copy the following into the AI conversation:

```
Implement export 009 (verify account / OTP) following the Stitch converter skill.

1. **Files to create:**
   - `apps/client_app/lib/src/features/auth/verify_account.screen.dart` (StatefulWidget with single fade animation).
   - `apps/client_app/lib/src/features/auth/widgets/verify_account_content.widget.dart` (Stateful widget managing OTP fields, timer, error).
   - `apps/client_app/lib/src/features/auth/widgets/otp_input_field.widget.dart` (Stateless custom input for one OTP digit).

2. **Localization:** Add the keys listed in this prompt to `app_en.arb` and `app_ar.arb`, then run `flutter gen-l10n`. Note: use `{email}` placeholder in `verifySubtitle`.

3. **Screen structure:**
   - Scaffold with background color `DorakColors.of(context).background`.
   - Header: `Row` with Back button (pop), Spacer(), brand text "Dorak" (`l10n.splashTitle`), Spacer().
   - Main content: `Center` with a `Container` (card) that has semi‑transparent background (`colors.surface.withOpacity(0.7)`), rounded corners, border, and shadow. Inside, a `Padding` with the `VerifyAccountContent` widget.
   - Apply a single `FadeTransition` (0.6s, easeOut) to the card (or the entire content) – match the HTML's `fade-in-up` with 0.1s delay.

4. **Content widget details:**
   - `emailOrPhone` parameter (String) – display masked (first char + "***@" + domain) in subtitle.
   - Build: Icon (mark_email_read), Title (`headlineLgMobile`), Subtitle (`bodyLg` with placeholder replacement), OTP Row, Error container (fixed height 24), Verify button (PrimaryButton with loading state), Resend row (Text + TextButton).
   - Use 6 `OtpInputField` widgets with controllers and focus nodes.
   - Implement auto‑advance on digit entry and backspace handling.
   - On verify: validate length 6, call `onVerify(code)`. On success, navigate to home (use callback or `Navigator.pushReplacement`). On failure, set error message.
   - Cooldown: start at 60 seconds on init, count down every second. Disable resend button during cooldown. Reset on resend call.

5. **Navigation:**
   - In `sign_up.screen.dart`, after successful sign‑up (stub), push `VerifyAccountScreen` with `emailOrPhone` and callbacks. The verify screen’s back button pops.
   - After verification, replace the stack with home screen or onboarding (use `_goHome()` pattern).

6. **Reuse:** The `otp_input_field` widget can be reused for any future OTP screens; keep it in `auth/widgets`.

7. **No hardcoded strings or colors** – use tokens and localization.

8. **Verification:** Run `flutter analyze`, `flutter test`, and `dart run tool/check_taxonomy.dart`. All must pass.

9. **Cleanup:** Delete the export folder after verification.
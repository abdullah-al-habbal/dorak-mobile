## 1. Understanding the Export (`008_create_your_account`)

**What’s in the folder:**
- `DESIGN.md` – global tokens (already implemented; **do not regenerate**).
- `code.html` – the screen layout and behavior source.

**Screen Purpose:**  
A dedicated sign‑up form, accessible from the “Create Account” button on `AuthEntryScreen` and from the “Log In” link on the login screen.

**Layout & Behavior (from HTML):**
- **Header:** Back button (arrow_back) + brand icon (spa) + brand name “Dorak”.
- **Main content** (centered, max‑width ~420px on mobile, split layout on desktop):
  - Left side: form with title “Create your account”, subtitle “Join Dorak for personalized grooming...”, and four floating‑label fields:
    1. Full Name
    2. Email or Phone
    3. Password (with visibility toggle)
    4. Confirm Password (with visibility toggle)
  - Right side (hidden on mobile): decorative image with glass‑morphism overlay card (“Premium Experience”).
- **Form actions:** “Create Account” button (primary, with loading spinner) and a footer link “Already have an account? Log In”.
- **Validation:** each field has an error message (hidden by default, shown when `data-error=true`). Password hint “At least 8 characters” shown below password field.
- **Animations:** Staggered fade‑up with 5 groups (0.1s to 0.5s delays). We can group into 3 animation phases to keep consistent with other screens.

---

## 2. Implementation Plan (Step‑by‑Step)

### 2.1. Feature & File Structure
Add to the existing `auth` feature folder (already created for 006 and 007):
```
apps/client_app/lib/src/features/auth/
├── auth_entry.screen.dart          (006)
├── login.screen.dart               (007)
├── sign_up.screen.dart             (NEW)   – StatefulWidget with staggered animations
├── widgets/
│   ├── auth_entry_content.widget.dart (006)
│   ├── login_content.widget.dart   (007)
│   ├── sign_up_content.widget.dart (NEW)  – Stateless, contains form
│   ├── auth_text_field.widget.dart (shared between 007 and 008)
│   └── auth_background_blobs.widget.dart (shared)
```

### 2.2. Localization (ARB)
Add the following keys to **both** `app_en.arb` and `app_ar.arb` (real Arabic translations). Reuse existing keys where possible (e.g., `loginButton` for the “Log In” link label).

| Key | English | Arabic |
|-----|---------|--------|
| `signUpTitle` | "Create your account" | "أنشئ حسابك" |
| `signUpSubtitle` | "Join Dorak for personalized grooming and effortless booking." | "انضم إلى دوراك للحصول على عناية شخصية وحجز سهل." |
| `signUpFullNameLabel` | "Full Name" | "الاسم الكامل" |
| `signUpEmailPhoneLabel` | "Email or Phone" | "البريد الإلكتروني أو الهاتف" |
| `signUpPasswordLabel` | "Password" | "كلمة المرور" |
| `signUpConfirmPasswordLabel` | "Confirm Password" | "تأكيد كلمة المرور" |
| `signUpPasswordHint` | "At least 8 characters" | "على الأقل 8 أحرف" |
| `signUpButton` | "Create Account" | "إنشاء حساب" |
| `signUpAlreadyHaveAccount` | "Already have an account?" | "لديك حساب بالفعل؟" |
| `signUpLogInLink` | "Log In" | "تسجيل الدخول" |
| `signUpErrorRequired` | "This field is required" | "هذا الحقل مطلوب" |
| `signUpErrorEmailPhone` | "Please enter a valid email or phone number" | "يرجى إدخال بريد إلكتروني أو رقم هاتف صحيح" |
| `signUpErrorPasswordLength` | "Password must be at least 8 characters" | "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل" |
| `signUpErrorPasswordMismatch` | "Passwords do not match" | "كلمات المرور غير متطابقة" |
| `signUpPremiumTitle` | "Premium Experience" | "تجربة متميزة" |
| `signUpPremiumDesc` | "Your journey to tailored grooming begins the moment you join. Experience seamless booking and personalized care." | "تبدأ رحلتك إلى العناية الشخصية بمجرد انضمامك. استمتع بتجربة حجز سلسة ورعاية مخصصة." |

After editing, run `flutter gen-l10n` in `packages/localization`.

### 2.3. Screen Implementation (`sign_up.screen.dart`)

- **StatefulWidget** with `SingleTickerProviderStateMixin`.
- Define an `AnimationController` (800 ms) and **three** staggered `CurvedAnimation` intervals (0.0–0.6, 0.1–0.7, 0.2–0.8) – as per the standard onboarding pattern.
- Scaffold with `backgroundColor: DorakColors.of(context).background`.
- Use a `Stack` with:
  1. **Background blobs** – reuse `AuthBackgroundBlobs` widget (if extracted) or replicate the two radial gradients (primary-fixed-dim and secondary-fixed).
  2. **SafeArea** with a `Column`:
     - **Header row**: `Row` with `IconButton` (back), `Spacer()`, brand icon + text (spa + “Dorak”), `Spacer()` (to balance). This matches the HTML’s header.
     - **Main content**: `Expanded` or `Spacer()` + `FadeTransition` for the content. We’ll have three animations for the major blocks:
       - Animation 0 → Title + subtitle (stagger-1+2).
       - Animation 1 → Form fields (stagger-3+4) – group all four fields together.
       - Animation 2 → Actions (button + footer link) – stagger-5.

- The content can be placed inside a `Padding` (horizontal 20, vertical 12) and a `Container` with `constraints: BoxConstraints(maxWidth: 420)` to centre it.

- For desktop, we will add a **right panel** with the decorative image and glass card. This can be included as a second child in a `Row` inside the `main` area. Use `LayoutBuilder` or `MediaQuery` to switch layout:
  - On small screens (width < 600 or 768): use `Column` with only the form.
  - On larger screens: use `Row` with `Expanded(flex:1)` for form and `Expanded(flex:1)` for the image panel.

### 2.4. Content Widget (`sign_up_content.widget.dart`)

We can either place the form directly in the screen or separate it into a stateless widget. Let’s create `SignUpContent` for clarity.

`SignUpContent` receives:
- `VoidCallback onBack`
- `VoidCallback onLoginLink` (navigate to login)
- `Function(String fullName, String emailPhone, String password) onSignUp`

It will manage form state (controllers, validation, loading state, password visibility toggles).

**Form implementation:**
- `Form` with `GlobalKey<FormState>`.
- Use the existing `AuthTextField` (from 007) for each field.
  - Full Name: `textInputType: TextInputType.name`, validator: required.
  - Email/Phone: `textInputType: TextInputType.emailAddress` (or phone), validator: required + email regex (basic) or phone check.
  - Password: `obscureText: true`, validator: min length 8.
  - Confirm Password: `obscureText: true`, validator: match the password controller’s text.
- For password hint (the “info” text below password field), we can add a `Padding` with `Text(l10n.signUpPasswordHint, style: DorakTypography.bodyMd, color: colors.outline)` below the password field.
- The “Create Account” button: use `PrimaryButton` with `onPressed: _validateAndSubmit`, and also support `isLoading` (show progress indicator inside button). We can add an optional `isLoading` parameter to `PrimaryButton` (if not already present, we may need to extend it; we can handle locally by wrapping the button with a Stack and conditionally showing a spinner).
- Footer: `Row` with `Text(l10n.signUpAlreadyHaveAccount)` and a `TextButton` for “Log In” with `onPressed: onLoginLink`.

### 2.5. Decorative Right Panel (Desktop)

- Inside a `Container` with `height: double.infinity` and `decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(...), fit: BoxFit.cover))`. Use a fallback asset image (e.g., from assets) in case the network image fails (errorBuilder).
- Overlay a glass card: a `Positioned` or `Align` at bottom‑left with a `Container` that has:
  - background: `colors.surface.withOpacity(0.8)` (or `Color(0xFFFDF8FD).withOpacity(0.7)`)
  - border: `Border.all(color: colors.primaryFixed.withOpacity(0.5))`
  - borderRadius: `BorderRadius.circular(16)`
  - shadow: `BoxShadow(color: colors.surfaceTint.withOpacity(0.08), blurRadius: 24)`
  - Inside: an `Icon(Icons.verified)` or similar, and two texts: “Premium Experience” (title-lg) and the description (body-md).
- Wrap the right panel with `Visibility` (visible only on larger screens) or use `SizedBox` with `constraints` and `Flexible`.

### 2.6. Navigation Wiring

In `main.dart`:
- Update `AuthEntryScreen.onSignup` to push `SignUpScreen`:
  ```dart
  onSignup: () => _push(SignUpScreen(
    onBack: () => Navigator.pop(context),
    onLoginLink: () => Navigator.pop(context), // or push login
    onSignUp: (fullName, emailPhone, password) {
      // stub: navigate to home or verification
      _goHome();
    },
  )),
  ```
- The back button in SignUpScreen should pop.
- The “Log In” link in the footer should pop to go back to the auth entry or push the login screen – we can simply pop to go back to the previous screen (which is the entry), or we can navigate to login. Since we have a login screen, we might want to push login. We'll pass a callback to handle that.

- **From LoginScreen** we also have a “Create Account” link; we should wire that to push SignUpScreen (or pop to entry and then push signup). For simplicity, we can push SignUpScreen from LoginScreen as well.

### 2.7. Reusable Components

- `AuthTextField`: created in 007, should be reused here for all fields.
- `AuthBackgroundBlobs`: extract to a separate widget to avoid duplication across 006, 007, 008.

### 2.8. Edge Cases & Gotchas

- **Password confirmation** validation requires comparing two fields. Use a `TextEditingController` for password and pass its value to the validator of confirm password.
- **Visibility toggle**: Use `bool _obscurePassword` and `_obscureConfirm` with `IconButton` to toggle.
- **Loading state**: Add a boolean `_isLoading` to the content widget; when true, show a `CircularProgressIndicator` inside the button and disable it.
- **Image loading**: Use `Image.network` with `errorBuilder` to fallback to a local asset (e.g., `Image.asset('assets/images/signup_placeholder.png')`). If we don't have an asset, we can use a `Container` with a gradient as fallback.
- **Responsive layout**: Use `LayoutBuilder` to conditionally show the right panel when `constraints.maxWidth > 700`. For mobile, the form takes full width.

### 2.9. Verification Gate

After implementation:
1. Run `flutter gen-l10n` (if ARB changed).
2. Run `flutter analyze` on `client_app`.
3. Run `flutter test` (if any tests added).
4. Run `dart run tool/check_taxonomy.dart`.

All must pass.

### 2.10. Cleanup

After verification, delete the export folder:  
`dorak-mobile/docs/stitch/exports/008_create_your_account/` (including `code.html` and `DESIGN.md`).

---

## 3. Deliverable Instructions for the AI Agent

Copy the following into the AI conversation:

```
Implement export 008 (sign‑up screen) following the Stitch converter skill.

1. **Files to create:**
   - `apps/client_app/lib/src/features/auth/sign_up.screen.dart` (StatefulWidget with staggered animations – 3 groups).
   - `apps/client_app/lib/src/features/auth/widgets/sign_up_content.widget.dart` (Stateless, contains form, validation, and actions).
   - Ensure `auth_text_field.widget.dart` and `auth_background_blobs.widget.dart` are already created (from 007 and 006) and reused.

2. **Localization:** Add the keys listed in this prompt to `app_en.arb` and `app_ar.arb`, then run `flutter gen-l10n`.

3. **Screen structure:**
   - Scaffold with background color `DorakColors.of(context).background`.
   - Stack with `AuthBackgroundBlobs` (two radial gradients) and SafeArea.
   - Header: `Row` with Back button (arrow_back), Spacer(), brand icon + text "Dorak", Spacer() (for balance).
   - Responsive layout: use `LayoutBuilder` – if width > 700, use a `Row` with two `Expanded` children: left form (max-width 420) and right decorative panel; else use a single `Column` with the form centered.
   - Three staggered FadeTransitions:
     * Animation 0 → Title + Subtitle.
     * Animation 1 → All four form fields (use `Column`).
     * Animation 2 → Create Account button + footer link.

4. **Content widget details:**
   - `Form` with `GlobalKey<FormState>`.
   - Use `AuthTextField` for Full Name, Email/Phone, Password, Confirm Password.
   - Validation: required for all; email/phone format check (basic regex); password min length 8; confirm password must match password.
   - Show error messages via `errorText` (will be displayed below the field).
   - Add password hint text below password field: `Text(l10n.signUpPasswordHint)` with `bodyMd` style and `outline` color.
   - Password visibility toggle: in each password field, add a suffix icon button that toggles `obscureText`.
   - `PrimaryButton` with `onPressed` that validates and calls `onSignUp(fullName, emailPhone, password)`. Provide a loading state (show circular progress inside button while `_isLoading`).
   - Footer: `Row` with `Text(l10n.signUpAlreadyHaveAccount)` and `TextButton` for "Log In" with `onPressed: onLoginLink`.

5. **Right decorative panel (desktop only):**
   - `Container` with `decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('...'), fit: BoxFit.cover))` – use the URL from the HTML. Add `errorBuilder` to show a fallback asset or gradient.
   - Overlay a glass card: use `Positioned` at bottom‑left with a `Container` that has semi‑transparent background, border, shadow, and child with `Icon(Icons.verified)` + title + description (using localization keys).
   - Make this panel visible only when `width > 700`.

6. **Navigation:**
   - In `main.dart`, wire `AuthEntryScreen.onSignup` to push `SignUpScreen` with callbacks: `onBack` (pop), `onLoginLink` (pop or push login – choose push login for better UX), and `onSignUp` (stub – navigate to home or verification).
   - Also, from `LoginScreen`, the "Create Account" link should push `SignUpScreen` (or pop and then push).

7. **Reuse:** Use the already created `AuthTextField` and `AuthBackgroundBlobs`; do not duplicate.

8. **No hardcoded strings or colors** – use tokens and localization.

9. **Verification:** Run `flutter analyze`, `flutter test`, and `dart run tool/check_taxonomy.dart`. All must pass.

10. **Cleanup:** Delete the export folder after verification.
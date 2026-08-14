## 1. Understanding the Export (`007_login_screen`)

**What’s in the folder:**
- `DESIGN.md` – global tokens (already implemented; **do not regenerate**).
- `code.html` – the screen layout and behavior source.

**Screen Purpose:**  
A dedicated login form, accessible from the “Log In” button on `AuthEntryScreen`.

**Layout & Behavior (from HTML):**
- **Header:** Back button (arrow_back) + brand name “Dorak” (static, no animation).
- **Main content** (centered, max-width ~448px):
  - Title: “Welcome Back” (`headline-lg-mobile` / `headline-lg` on desktop).
  - Subtitle: “Sign in to your account” (`body-lg`).
  - Form with two fields:
    - **Email/Phone** – floating label, bottom border, focus state changes border to primary and background tint.
    - **Password** – floating label, bottom border, with a visibility toggle (eye icon), and an *error state* shown (the HTML includes a `error` class on the input + an error message with icon). This demonstrates validation feedback.
  - **Forgot Password?** – text link (label-lg, primary color) aligned right.
  - **Log In button** – primary filled button with trailing arrow that shifts on hover. Also contains a hidden loading overlay (for future use).
- **Footer:** “Don’t have an account? Create Account” – a text link with underline on hover.
- **Background:** Same decorative blurred blobs as in 006.

**Animations:**  
- `fade-slide-up` with staggered delays:
  - Title + subtitle: no delay (or delay 0).
  - Form fields: `delay-100`.
  - Forgot Password link: `delay-200`.
  - Log In button: `delay-300`.
  - Footer (create account link): `delay-300`.
- Header is static (no animation).

**Interactive Elements:**
- Back button → pop to `AuthEntryScreen`.
- Forgot Password → navigate to a (future) password reset screen.
- Log In → perform authentication (stub for now; later will call API).
- Create Account → navigate to a (future) sign-up screen.

---

## 2. Implementation Plan (Step‑by‑Step)

### 2.1. Feature & File Structure
Add to the existing `auth` feature folder (already created for 006):
```
apps/client_app/lib/src/features/auth/
├── auth_entry.screen.dart          (from 006)
├── login.screen.dart               (NEW)
├── widgets/
│   ├── auth_entry_content.widget.dart (from 006)
│   └── login_content.widget.dart   (NEW)
```
Also consider adding a **reusable floating-label text field** – either inside `auth/widgets/` or, if it proves broadly reusable (e.g., in sign‑up, profile), later promote to `design_system`. For now, keep it local as `auth_text_field.widget.dart`.

### 2.2. Localization (ARB)
Add the following keys to **both** `app_en.arb` and `app_ar.arb` (real Arabic translations):

| Key | English | Arabic |
|-----|---------|--------|
| `loginTitle` | "Welcome Back" | "مرحباً بعودتك" |
| `loginSubtitle` | "Sign in to your account" | "سجّل الدخول إلى حسابك" |
| `loginEmailPhoneLabel` | "Email or Phone" | "البريد الإلكتروني أو الهاتف" |
| `loginPasswordLabel` | "Password" | "كلمة المرور" |
| `loginForgotPassword` | "Forgot Password?" | "نسيت كلمة المرور؟" |
| `loginButton` | "Log In" | "تسجيل الدخول" |
| `loginSignUpPrompt` | "Don't have an account?" | "ليس لديك حساب؟" |
| `loginCreateAccountLink` | "Create Account" | "إنشاء حساب" |
| `loginErrorInvalidCredentials` | "Invalid email or password" | "البريد الإلكتروني أو كلمة المرور غير صحيحة" |

Also reuse `loginButton` for the CTA (same as 006’s `authLogIn`? Could reuse if identical, but better to keep separate keys per screen for future flexibility). We already have `authLogIn` from 006 – we can reuse that for the CTA label, but we need separate labels for the field placeholders and error. We'll keep `loginButton` distinct to avoid confusion.

After editing, run `flutter gen-l10n` in `packages/localization`.

### 2.3. Screen Implementation (`login.screen.dart`)

- **StatefulWidget** with `SingleTickerProviderStateMixin`.
- Define an `AnimationController` (800 ms) and three staggered `CurvedAnimation` intervals (0.0–0.6, 0.1–0.7, 0.2–0.8) – same pattern as other screens.
- Scaffold with `backgroundColor: DorakColors.of(context).background`.
- Use a `Stack` with:
  1. Decorative blobs (identical to 006; can be extracted to a shared widget, but for now duplicate locally or create `_BackgroundBlobs` widget).
  2. A `SafeArea` with a `Column`:
     - **Header row**: `Row` with `BackButton` (icon button), `Spacer()`, `Text("Dorak")`, `Spacer()` for balance. (We can use `OnboardingHeader`? It has brandLabel and skip/locale – not suitable. We'll build a simple header.)
     - **Main content**: `Expanded` or `Spacer()` + `FadeTransition` for the content widget – we'll have three fade transitions: one for the title block, one for the form, one for the button and footer? But the HTML has staggered delays for specific groups. We can allocate:
       - Animation 0 → title + subtitle (together).
       - Animation 1 → form fields (email + password).
       - Animation 2 → forgot password link + login button + footer (all together, or we can split button and footer but we only have 3 animations). The easiest is to wrap all the form elements (fields, forgot link, button) in a `Column` and apply the same animation. That approximates the staggered effect. For more precise timing, we could use a `Tween` with different `Interval`s inside the content widget, but that's overkill. We'll follow the same pattern as other screens: use the three animations for the major blocks.

#### Suggested structure inside the `Column`:
- `FadeTransition(opacity: _staggeredAnimations[0], child: _buildHeader())` – contains `Column` with title and subtitle.
- `SizedBox(height: 24)`.
- `FadeTransition(opacity: _staggeredAnimations[1], child: _buildForm())` – contains the two text fields.
- `SizedBox(height: 8)`.
- `FadeTransition(opacity: _staggeredAnimations[2], child: _buildActions())` – contains the forgot password link, login button, and footer (in a Column with spacing).

This will give a nice staggered entrance.

### 2.4. Content Widget (`login_content.widget.dart` or directly in screen)

We can choose to keep the content inside the screen or separate it into a widget. Since the screen is relatively simple, we can put the build methods inside the screen. However, to follow the pattern (DiscoveryScreen uses `DiscoveryContent`), we could create `LoginContent` stateless widget that receives callbacks. Let's do that for consistency.

`LoginContent` receives:
- `VoidCallback onBack`
- `VoidCallback onForgotPassword`
- `VoidCallback onLogin` (or `Function(String email, String password)` if we handle form state)
- `VoidCallback onCreateAccount`

It will manage the form state (email, password, error visibility, loading state) locally.

**Form implementation:**
- Use `Form` with `GlobalKey<FormState>`.
- Two `TextFormField`s with `InputDecoration`:
  - `labelText`, `floatingLabelBehavior: FloatingLabelBehavior.always` (or auto).
  - `border: UnderlineInputBorder()` with custom color (use `outlineVariant`).
  - `enabledBorder` and `focusedBorder` to match design.
  - For password field, add a `suffixIcon` with `IconButton` to toggle `obscureText`.
  - For error state, use `validator` and display error text via `TextFormField`'s `errorText` (or use a separate widget below). The HTML shows an error icon + text below the field – we can achieve that by setting `errorText` which shows the error message, but it will also style the border automatically. We can customize the error style to match the design (icon + text). We can use `TextFormField` with `decoration: InputDecoration(errorText: ...)` – it will show the error below. That is fine.

- The "Log In" button should call `_validateAndSubmit()` – if valid, invoke `onLogin(email, password)`. For now, we can just pass the data upward.

- The "Forgot Password" link: use `TextButton` with style `textStyle: DorakTypography.labelLg, foregroundColor: colors.primary` and `onPressed: onForgotPassword`.

- The footer: `Row` with `Text(l10n.loginSignUpPrompt)` and a `TextButton` for "Create Account" (underline on hover – we can use `TextButton` with custom style; or use `GestureDetector` + `AnimatedContainer` for underline, but we can simply rely on `TextButton`'s hover color change).

### 2.5. Custom Floating‑Label Text Field

Given that we have two fields and will likely reuse this in sign‑up, it's worth creating a reusable `AuthTextField` widget inside `auth/widgets/`:

- Accepts `labelText`, `onChanged`, `obscureText`, `suffixIcon`, `validator`, `errorText`.
- Uses `TextFormField` with the desired decoration.
- This keeps the content widget clean.

We can implement it with `InputDecoration` that matches the design:
```dart
decoration: InputDecoration(
  labelText: label,
  floatingLabelBehavior: FloatingLabelBehavior.auto,
  border: UnderlineInputBorder(
    borderSide: BorderSide(color: colors.outlineVariant, width: 1),
  ),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: colors.outlineVariant, width: 1),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: colors.primary, width: 2),
  ),
  errorBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: colors.error, width: 1),
  ),
  focusedErrorBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: colors.error, width: 2),
  ),
  filled: true,
  fillColor: colors.primaryContainer.withOpacity(0.05),
  // etc.
)
```

We'll also adjust the label style and content padding.

### 2.6. Navigation Wiring

In `main.dart`:
- Update `AuthEntryScreen`'s `onLogin` to push `LoginScreen`:
  ```dart
  onLogin: () => _push(LoginScreen(
    onBack: () => Navigator.pop(context),
    onForgotPassword: () => _push(ForgotPasswordScreen()), // later
    onCreateAccount: () => _push(SignUpScreen()), // later
  )),
  ```
- The `LoginScreen` will have a `onLogin` callback that performs authentication (stub). For now, we can just navigate to the home screen after a successful login (will be implemented later). Or we can keep it as a stub that prints.

- The back button in LoginScreen should pop.

- The "Create Account" link in LoginScreen should navigate to the sign-up screen (future). For now, we can show a placeholder or just pop.

### 2.7. Decorative Blobs

Same as 006 – we can either duplicate the code or create a shared `AuthBackgroundBlobs` widget in `auth/widgets/` to reuse across both screens. Since both screens use the same blobs, extract it to avoid duplication.

### 2.8. Edge Cases & Gotchas

- **Header**: The back button should be a `IconButton` with `onPressed: widget.onBack` and a custom style (circular, hover background). Use `Material` with `shape: CircleBorder()` and `hoverColor`.
- **Form state**: Manage `TextEditingController`s and `FocusNode`s for proper label animation.
- **Password visibility**: Use a `bool _obscure` state to toggle.
- **Error state**: The HTML shows the error message by default (the password field has class `error`). In our implementation, we'll only show the error when validation fails. That's fine.
- **Loading state**: The button can have a `isLoading` parameter that shows a `CircularProgressIndicator` inside the button, replacing the label. We can add that to `PrimaryButton` or handle locally.

### 2.9. Verification Gate

After implementation:
1. Run `flutter gen-l10n` (if ARB changed).
2. Run `flutter analyze` on `client_app`.
3. Run `flutter test` (if any tests added).
4. Run `dart run tool/check_taxonomy.dart`.

All must pass.

### 2.10. Cleanup

After verification, delete the export folder:  
`dorak-mobile/docs/stitch/exports/007_login_screen/` (including `code.html` and `DESIGN.md`).

---

## 3. Deliverable Instructions for the AI Agent

Copy the following into the AI conversation:

```
Implement export 007 (login screen) following the Stitch converter skill.

1. **Files to create:**
   - `apps/client_app/lib/src/features/auth/login.screen.dart` (StatefulWidget with staggered animations).
   - `apps/client_app/lib/src/features/auth/widgets/login_content.widget.dart` (Stateless, contains form and actions).
   - `apps/client_app/lib/src/features/auth/widgets/auth_text_field.widget.dart` (reusable floating-label text field).
   - Optionally: `auth_background_blobs.widget.dart` (shared between 006 and 007).

2. **Localization:** Add keys listed below to `app_en.arb` and `app_ar.arb`, then run `flutter gen-l10n`.

3. **Screen structure:**
   - Scaffold with background color `DorakColors.of(context).background`.
   - Stack with background blobs (radial gradients) and SafeArea.
   - Header: Back button (arrow_back) + brand text "Dorak" (use `l10n.splashTitle`).
   - Three staggered FadeTransitions:
     * Animation 0 → Title + Subtitle (wrap in Column).
     * Animation 1 → Form (two text fields).
     * Animation 2 → Forgot Password link + Login button + Footer (Create Account link).
   - Use `SizedBox` for spacing between blocks.

4. **Content widget details:**
   - `Form` with `GlobalKey`.
   - Two `AuthTextField`s: one for email/phone (no obscure), one for password (obscure, with suffix toggle).
   - Validation: add a simple non-empty check for both fields; for email, a regex check (basic).
   - Show error messages inline via `errorText` (when validation fails).
   - Forgot Password: `TextButton` with `onPressed: onForgotPassword`.
   - Login button: `PrimaryButton` with `onPressed: _submitForm` – call `onLogin(email, password)`.
   - Footer: `Row` with `Text(l10n.loginSignUpPrompt)` and a `TextButton` for "Create Account" with `onPressed: onCreateAccount`.

5. **Navigation:**
   - In `main.dart`, update `AuthEntryScreen.onLogin` to push `LoginScreen` (with callbacks for back, forgot password, create account – stubs for now).
   - Back button in LoginScreen → `Navigator.pop(context)`.

6. **Reuse components:**
   - `AuthTextField` should be local to auth for now; if it becomes reused across apps, later promote to design_system.
   - Background blobs: optionally extract to `auth/widgets/auth_background_blobs.widget.dart` to reuse with 006.

7. **No hardcoded strings or colors** – use tokens and localization.

8. **Verification:** Run `flutter analyze`, `flutter test`, and `dart run tool/check_taxonomy.dart`. All must pass.

9. **Cleanup:** Delete the export folder after verification.
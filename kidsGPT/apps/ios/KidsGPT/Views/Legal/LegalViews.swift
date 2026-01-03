import SwiftUI

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Last updated: January 2026")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Introduction
                    PolicySection(
                        title: "Introduction",
                        content: """
                        KidsGPT ("we," "our," or "us") is committed to protecting the privacy of children and their families. This Privacy Policy explains how we collect, use, and safeguard information when you use our application.

                        We are fully compliant with the Children's Online Privacy Protection Act (COPPA) and take special care to protect information from users under 13 years of age.
                        """
                    )

                    // Information We Collect
                    PolicySection(
                        title: "Information We Collect",
                        content: """
                        We collect the following types of information:

                        • **Account Information**: Parent/guardian email address and display name
                        • **Child Profiles**: Child's name, age, and learning interests (provided by parent)
                        • **Chat Content**: Conversations between children and our AI assistant
                        • **Usage Data**: How the app is used to improve our services

                        We do NOT collect:
                        • Precise location data
                        • Contact lists
                        • Photos or videos (unless explicitly shared)
                        • Third-party account information
                        """
                    )

                    // How We Use Information
                    PolicySection(
                        title: "How We Use Information",
                        content: """
                        We use collected information to:

                        • Provide age-appropriate AI responses
                        • Personalize learning experiences
                        • Allow parents to monitor their child's activity
                        • Improve our service and safety features
                        • Communicate important updates to parents

                        We never use children's information for advertising or sell data to third parties.
                        """
                    )

                    // Data Security
                    PolicySection(
                        title: "Data Security",
                        content: """
                        We implement industry-standard security measures:

                        • End-to-end encryption for all communications
                        • Secure data storage with regular backups
                        • Access controls and authentication
                        • Regular security audits

                        All data is stored on secure servers and access is strictly limited.
                        """
                    )

                    // Parental Rights
                    PolicySection(
                        title: "Parental Rights (COPPA)",
                        content: """
                        Parents and guardians have the right to:

                        • Review their child's personal information
                        • Request deletion of their child's data
                        • Refuse further collection of their child's information
                        • Receive notice of any material changes to this policy

                        To exercise these rights, contact us at privacy@kidsgpt.com
                        """
                    )

                    // Contact
                    PolicySection(
                        title: "Contact Us",
                        content: """
                        For questions about this Privacy Policy or our practices:

                        Email: privacy@kidsgpt.com
                        Address: [Company Address]

                        We respond to all inquiries within 48 hours.
                        """
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms of Service")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Last updated: January 2026")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Acceptance
                    PolicySection(
                        title: "1. Acceptance of Terms",
                        content: """
                        By accessing or using KidsGPT, you agree to be bound by these Terms of Service. If you are a parent or guardian creating an account for your child, you agree to these terms on behalf of your child.

                        If you do not agree to these terms, please do not use our service.
                        """
                    )

                    // Service Description
                    PolicySection(
                        title: "2. Service Description",
                        content: """
                        KidsGPT provides an AI-powered educational companion for children ages 3-13. Our service includes:

                        • Interactive AI chat for learning
                        • Age-appropriate content filtering
                        • Parent monitoring dashboard
                        • Usage limits for healthy screen time

                        We reserve the right to modify or discontinue features at any time.
                        """
                    )

                    // User Responsibilities
                    PolicySection(
                        title: "3. User Responsibilities",
                        content: """
                        Parents/Guardians agree to:
                        • Provide accurate information about their children
                        • Monitor their child's use of the service
                        • Report any inappropriate content or behavior
                        • Keep account credentials secure

                        Users agree NOT to:
                        • Attempt to bypass safety filters
                        • Share inappropriate content
                        • Use the service for any illegal purpose
                        • Create multiple accounts to circumvent limits
                        """
                    )

                    // Content and Safety
                    PolicySection(
                        title: "4. Content and Safety",
                        content: """
                        We employ multiple layers of content safety:

                        • AI responses are filtered for age-appropriateness
                        • Harmful or inappropriate content is blocked
                        • Conversations may be reviewed for safety
                        • Parents can view all conversation history

                        While we strive for 100% safety, AI systems can occasionally produce unexpected outputs. Parents should maintain oversight.
                        """
                    )

                    // Subscription and Payment
                    PolicySection(
                        title: "5. Subscription and Payment",
                        content: """
                        KidsGPT offers:
                        • Free tier with limited daily messages
                        • Basic tier with expanded features
                        • Premium tier with unlimited access

                        Subscriptions renew automatically unless cancelled. Refunds are provided according to our refund policy.
                        """
                    )

                    // Limitation of Liability
                    PolicySection(
                        title: "6. Limitation of Liability",
                        content: """
                        KidsGPT is provided "as is" without warranties of any kind. We are not liable for:

                        • Educational outcomes
                        • Service interruptions
                        • Content generated by AI
                        • Third-party services

                        Our total liability is limited to the amount paid for the service.
                        """
                    )

                    // Changes to Terms
                    PolicySection(
                        title: "7. Changes to Terms",
                        content: """
                        We may update these terms from time to time. We will notify users of material changes via email or in-app notification.

                        Continued use after changes constitutes acceptance of new terms.
                        """
                    )

                    // Contact
                    PolicySection(
                        title: "8. Contact",
                        content: """
                        For questions about these Terms of Service:

                        Email: legal@kidsgpt.com
                        """
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Policy Section Component
struct PolicySection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text(LocalizedStringKey(content))
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - Legal Links Footer
struct LegalLinksFooter: View {
    @State private var showPrivacy = false
    @State private var showTerms = false

    var body: some View {
        HStack(spacing: 16) {
            Button("Privacy Policy") { showPrivacy = true }
            Text("•")
                .foregroundColor(.secondary)
            Button("Terms of Service") { showTerms = true }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTerms) {
            TermsOfServiceView()
        }
    }
}

#Preview("Privacy Policy") {
    PrivacyPolicyView()
}

#Preview("Terms of Service") {
    TermsOfServiceView()
}

#Preview("Legal Links") {
    LegalLinksFooter()
}

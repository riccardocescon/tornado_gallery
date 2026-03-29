part of '../encryption_page.dart';

class _PasswordCard extends StatefulWidget {
  const _PasswordCard();

  @override
  State<_PasswordCard> createState() => __PasswordCard();
}

class __PasswordCard extends State<_PasswordCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: AppStyle.cardBorderRadius,
        boxShadow:
            context.isDarkMode
                ? null
                : [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Password", style: context.textTheme.titleMedium),
          Text(
            "This password will be used to encrypt your images",
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: PasswordFormField(
              onChanged: (value) {
                context.read<EncryptionPageBloc>().add(
                  EncryptionPageEvent.setPassword(password: value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

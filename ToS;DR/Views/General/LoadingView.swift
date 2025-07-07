import SwiftUI

struct LoadingState {
    enum Status {
        case idle
        case loading
        case success
        case error
    }
    
    var status: Status
    var message: String?
    var retryAction: (() -> Void)?
    
    static let idle = LoadingState(status: .idle)
    static let loading = LoadingState(status: .loading)
    static func success(message: String? = nil) -> LoadingState {
        LoadingState(status: .success, message: message)
    }
    static func error(message: String? = nil, retryAction: (() -> Void)? = nil) -> LoadingState {
        LoadingState(status: .error, message: message, retryAction: retryAction)
    }
}

struct LoadingView: View {
    var state: LoadingState
    var hideWhenIdle: Bool = true
    
    @State private var isAnimating = false
    
    var body: some View {
        if hideWhenIdle && state.status == .idle {
            EmptyView()
        } else {
            VStack(spacing: 20) {
                switch state.status {
                case .idle:
                    EmptyView()
                    
                case .loading:
                    LoadingIndicatorView(isAnimating: $isAnimating)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                isAnimating = true
                            }
                        }
                    
                    Text(state.message ?? String(localized: "loading_message"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                case .success:
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .onAppear {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isAnimating = true
                                }
                            }
                        
                        if let message = state.message {
                            Text(message)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                case .error:
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.red)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .onAppear {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isAnimating = true
                                }
                            }
                        
                        if let message = state.message {
                            Text(message)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        if let retryAction = state.retryAction {
                            Button(action: retryAction) {
                                Text(String(localized: "retry_button"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(.blue)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .padding(32)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.separator), lineWidth: 0.5)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .padding()
        }
    }
}

struct LoadingIndicatorView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                .frame(width: 48, height: 48)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 48, height: 48)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingView(state: .loading)
        LoadingView(state: .success(message: "Data loaded successfully"))
        LoadingView(state: .error(message: "Network connection lost", retryAction: {}))
    }
    .padding()
}

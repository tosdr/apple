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
    
    var body: some View {
        if hideWhenIdle && state.status == .idle {
            EmptyView()
        } else {
            VStack(spacing: 16) {
                switch state.status {
                case .idle:
                    EmptyView()
                    
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding(.bottom, 8)
                    
                    Text(state.message ?? String(localized: "loading_message"))
                        .foregroundColor(.secondary)
                    
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        .padding(.bottom, 8)
                    
                    if let message = state.message {
                        Text(message)
                            .foregroundColor(.secondary)
                    }
                    
                case .error:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 50, height: 44)
                        .foregroundColor(.red)
                        .padding(.bottom, 8)
                    
                    if let message = state.message {
                        Text(message)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let retryAction = state.retryAction {
                        Button(action: retryAction) {
                            Text(String(localized: "retry_button"))
                                .bold()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    //.fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
            )
            .padding()
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

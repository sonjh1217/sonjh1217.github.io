---
title:  "State & Binding"

categories:
  - SwiftUI
tags:
  - State
---

Source: [https://developer.apple.com/tutorials/app-dev-training/managing-data-flow-between-views](https://developer.apple.com/tutorials/app-dev-training/managing-data-flow-between-views)

## State and Binding
![Image](https://github.com/user-attachments/assets/59b59a0e-c22c-425e-9d66-917afc11fe81)
For SwiftUI, to manage a single source of truth, you can use @State.<br>
@ denotes a property wrapper, which encapsulates a common property-initialization pattern, helping you add behaviors to your properties efficiently.
When a @State property value changes, the system automatically redraws the view using the updated values of the property.<br>
Declare @State properties as private so that they can be accessed only within the view in which you define them.

![Image](https://github.com/user-attachments/assets/b888efb6-37d7-4ae8-b1cb-61b6fd773303)
A property that you wrap with @Binding shares read and write access with an existing source of truth.<br>
@Binding does not store the property directly.<br>
The system establishes dependencies between the data in @State and the child view that contains the @Binding. <br>
You don’t need to write code to observe data because the system automatically updates the relevant views to reflect changes made to the source of truth.

## State
~~~
struct DetailEditView: View {
    @State private var scrum = DailyScrum.emptyScrum
    
    var body: some View {
        Form {
            Section(header: Text("Meeting Info")) {
                TextField("Title", text: $scrum.title)
                HStack {
                    Slider(value: $scrum.lengthInMinutesAsDouble, in: 5...30, step: 1) {
                        Text("Length")
                    }
                    Spacer()
                    Text("\(scrum.lengthInMinutes) minutes")
                }
            }
        }
    }
}
~~~
{: .language-swift}

~~~
.sheet(isPresented: $isPresentingEditView) {
    NavigationStack {
        DetailEditView()
            .navigationTitle(scrum.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresentingEditView = false
                    }
                }
            }
    }
}
}
~~~
{: .language-swift}

For write access, you need to use $.
For sheet, isPresentingEditView value decides whether to present a view or not. In this case, you need to bind the value using $ so that SwiftUI can track changes and updates the view accordingly. 
For text, the system can automatically update the view when the value it displays changes because SwiftUI tracks state changes inside the view. 


## Binding

### Constant Binding
~~~
struct ThemePicker: View {
    @Binding var selection: Theme
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ThemePicker(selection: .constant(.periwinkle))
}
~~~
{: .language-swift}

a binding to a hard-coded, immutable value

## Projected Value

~~~
List($scrums) { $scrum in
                NavigationLink(destination: DetailView(scrum: scrum)) {
                    CardView(scrum: scrum)
                }
                .listRowBackground(scrum.theme.mainColor)
            }
~~~
{: .language-swift}

"$scrum"
The $ prefix accesses the projectedValue of a wrapped property. The projected value of the scrums binding is another binding.

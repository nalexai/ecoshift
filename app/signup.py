import streamlit as st


def app(user_tier, tier_charges):
    st.markdown("#### Create an Eco Wallet")
    token_id = st.text_input("Your wallet name (must end in .eco)", key="token_id")

    if st.button(
        "Generate Wallet!", key=None, help=None, on_click=None, args=None, kwargs=None
    ):
        st.write(
            "You have successfully generated your Tier 1 Eco Wallet. Your wallet name is "
            + token_id
            + ". Please keep it safe."
        )
        user_tier = 1
        st.image("image/tier1.png", width=250)

    return user_tier
